#!/bin/bash
#set -e
#$1 size
#$2 gene

export i=$1
export g=$2

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

pushd $PROJ_DIR > /dev/null

mkdir -p $i/genes_processed/$g

/usr/bin/time -o $i/genes_processed/$g/time_UPPFAA.txt -f "%e,%M" run_upp.py -s $i/sequences/faa/$g.fasta -B 100000 -M -1 -T 0.66 -m amino -d $i/genes_processed/$g -x 6 -o UPPFAA > $i/genes_processed/$g/upp_faa.out 2> $i/genes_processed/$g/upp_faa.err

temp=`mktemp -t XXXXXX.fa`
sitemask=0.95
seqmask=0.66

echo Masking sites with more than 95% gaps ...
10kBacGenomes/mask_sites.sh $i/genes_processed/$g/UPPFAA_alignment_masked.fasta $temp $sitemask

echo Masking sequences with more than 66% gaps ...
#echo Masking sequences with more than 80% gaps ...
10kBacGenomes/mask_sequences.sh $temp $i/genes_processed/$g/UPPFAA_alignment_masked_filtered.fasta $seqmask
rm $temp

echo "Inferring best model"
mkdir $i/genes_processed/$g/tmp
pushd $i/genes_processed/$g/tmp > /dev/null
    cp ../UPPFAA_alignment_masked.fasta align.fa
    perl $PROJ_DIR/bin/ProteinModelSelection.pl align.fa > ../best_model.txt
popd > /dev/null
rm -r $i/genes_processed/$g/tmp

export MODEL=`cut -f4 -d ' ' $i/genes_processed/$g/best_model.txt`
[[ $MODEL == MT* ]] && export MODEL="LG"

echo "Running Fasttree first time"
export OMP_NUM_THREADS=3

FastTreeMP -lg -gamma -seed 12345 -log $i/genes_processed/$g/fasttree.log < $i/genes_processed/$g/UPPFAA_alignment_masked_filtered.fasta  > $i/genes_processed/$g/fasttree.nwk

echo "Treeshrink'ing"
run_treeshrink.py -t $i/genes_processed/$g/fasttree.nwk -a $i/genes_processed/$g/UPPFAA_alignment_masked_filtered.fasta -o $i/genes_processed/$g/fasttree_shrunk

nw_labels -I $i/genes_processed/$g/fasttree_shrunk/fasttree_0.05.nwk > $i/genes_processed/$g/remaining_after_shrunk.txt

bin/faSomeRecords $i/genes_processed/$g/UPPFAA_alignment_masked_filtered.fasta  $i/genes_processed/$g/remaining_after_shrunk.txt $i/genes_processed/$g/UPPFAA_alignment_masked_filtered_shrunk.fasta

echo "Running Fasttree second time"
FastTreeMP -lg -gamma -seed 12345 -log $i/genes_processed/$g/fasttree_r2.log < $i/genes_processed/$g/UPPFAA_alignment_masked_filtered_shrunk.fasta  > $i/genes_processed/$g/fasttree_r2.nwk

python scripts/resolve_polytomies.py $i/genes_processed/$g/fasttree_r2.nwk > $i/genes_processed/$g/fasttree_r2_resolved.nwk

echo "Runinng raxml three times"

mkdir -p $i/genes_processed/$g/{g1,g2,g3}

raxml(){

    pushd $i/genes_processed/$g/g1 > /dev/null
    raxmlHPC-PTHREADS-SSE3 -T 6 -m PROTCAT${MODEL} -F -f D -D -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta -p 12345 -n RUN -t ../fasttree_r2_resolved.nwk 2> raxml.err > raxml.log 
    popd > /dev/null

    pushd $i/genes_processed/$g/g2 > /dev/null
    raxmlHPC-PTHREADS-SSE3 -T 6 -m PROTCAT${MODEL} -F -f D -D -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta -p 12345 -n RUN  2> raxml.err > raxml.log
    popd > /dev/null

    pushd $i/genes_processed/$g/g3 > /dev/null
    raxmlHPC-PTHREADS-SSE3 -T 6 -m PROTCAT${MODEL} -F -f D -D -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta -p 23456 -n RUN  2> raxml.err > raxml.log
    popd > /dev/null

	echo "raxml topology search ended. now optimizing branch lenghts."

    pushd $i/genes_processed/$g/g1 > /dev/null
    raxmlHPC-PTHREADS-SSE3 -T 6 -m PROTGAMMA${MODEL} -f e -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta -t RAxML_result.RUN -n RUNGAMMA -p 12345 2> raxml_gamma.err > raxml_gamma.log || return
    popd > /dev/null

    pushd $i/genes_processed/$g/g2 > /dev/null
    raxmlHPC-PTHREADS-SSE3 -T 6 -m PROTGAMMA${MODEL} -f e -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta -t RAxML_result.RUN -n RUNGAMMA -p 12345 2> raxml_gamma.err > raxml_gamma.log || return
    popd > /dev/null

    pushd $i/genes_processed/$g/g3 > /dev/null
    raxmlHPC-PTHREADS-SSE3 -T 6 -m PROTGAMMA${MODEL} -f e -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta -t RAxML_result.RUN -n RUNGAMMA -p 23456 2> raxml_gamma.err > raxml_gamma.log || return
    popd > /dev/null


} 
export -f raxml

# if raxml fails while calculating branch lengths, "if raxml" statement will return false.
if raxml ; then
    grep "Final GAMMA" $i/genes_processed/$g/*/RAxML_info.RUNGAMMA | sort -k4n | tail -n 1 | cut -f1 -d ":"| sed "s/_info/_result/g" > $i/genes_processed/$g/bestTreename.txt
    cp `cat $i/genes_processed/$g/bestTreename.txt` $i/genes_processed/$g/bestTree.nwk
else
    echo "raxml failed. trying iqtree"
    # pop one time since raxml failed.
    popd > /dev/null
    #make sure we are in PROJ_DIR. just to be on the safe side
    cd $PROJ_DIR
    pushd $i/genes_processed/$g/g1 > /dev/null
    ln -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta
    iqtree -ntmax 6 -m LG+G4 -s UPPFAA_alignment_masked_filtered_shrunk.fasta -te RAxML_result.RUN -seed 12345 > iqtree.out 2> iqtree.err    
    popd > /dev/null

    pushd $i/genes_processed/$g/g2 > /dev/null
    ln -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta
    iqtree -ntmax 6 -m LG+G4 -s UPPFAA_alignment_masked_filtered_shrunk.fasta -te RAxML_result.RUN -seed 12345 > iqtree.out 2> iqtree.err
    popd > /dev/null

    pushd $i/genes_processed/$g/g3 > /dev/null
    ln -s ../UPPFAA_alignment_masked_filtered_shrunk.fasta
    iqtree -ntmax 6 -m LG+G4 -s UPPFAA_alignment_masked_filtered_shrunk.fasta -te RAxML_result.RUN -seed 12345 > iqtree.out 2> iqtree.err
    popd > /dev/null    

    grep "BEST SCORE" $i/genes_processed/$g/*/UPPFAA_alignment_masked_filtered_shrunk.fasta.log | sort -k5n | tail -n 1 | cut -f1 -d ":"| sed "s/.log/.treefile/g" > $i/genes_processed/$g/bestTreename.txt
    cp `cat $i/genes_processed/$g/bestTreename.txt` $i/genes_processed/$g/bestTree.nwk
fi
    

popd > /dev/null

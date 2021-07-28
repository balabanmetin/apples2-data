#! /usr/bin/env bash

source activate three
pushd $1

ALL=`nproc --all`
export UPPCORES=`python3 -c "print(max(1,$ALL//6))"` # 6 cores per upp job
export XARGSCORES=`python3 -c "print($ALL//$UPPCORES)"`
export TMPDIR=/dev/shm
export TMP=$TMPDIR

#
TMP=`mktemp -t XXXXXXX.fa`
while read sp; do echo /oasis/tscc/scratch/balaban/apples2/data/multigene/metagenomic/assembly/query_aln/$sp/output_backtranslated_alignment_masked_nothird.fasta; done < select.txt | paste -s -d ' ' |  xargs ~/bin/catfasta2phyml.pl -f -c > $TMP
#
python /oasis/projects/nsf/uot138/balaban/btol/scripts/dedupe.py $TMP concat_dedup.fa dupmap.txt
#
rm $TMP
#
#
faSomeRecords concat_dedup.fa  queries.txt query.fa
faSomeRecords -exclude concat_dedup.fa queries.txt ref.fa
/oasis/projects/nsf/uot138/balaban/btol/scripts/reestimate_backbone.sh .
#

cp true_me.fasttree backbone.nwk
#paste -s -d ' ' queries.txt | xargs nw_prune true_me.fasttree > backbone.nwk
#
python3 ~/apples/run_apples.py -q query.fa -s ref.fa -t backbone.nwk -o apples.jplace -D -f 0.2 -b 25 > apples.out 2> apples.err
#
rm apples.newick
gappa examine graft --jplace-path=apples.jplace --out-dir=.
#
/oasis/projects/nsf/uot138/balaban/btol/scripts/measure.sh . apples.newick /oasis/projects/nsf/uot138/balaban/btol/trees/astral.lpp.nwk  backbone.nwk

popd

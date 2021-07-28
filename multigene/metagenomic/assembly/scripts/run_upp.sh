#! /usr/bin/env bash

# $1 gene
# $2 dir

source activate wolmeta
conda activate wolmeta

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
pushd $PROJ_DIR > /dev/null

export dir=$2
export UPPCORES=6 # 6 cores per upp job
export TMPDIR=/dev/shm
export TMP=$TMPDIR

	mkdir -p ${dir}/$1
        cp faa/${1}.faa ${dir}/$1/query.fasta

        bin/faSomeRecords -exclude alignments/faa/${1}.fasta queries.txt ${dir}/$1/ref.fa
        grep ">" ${dir}/$1/ref.fa | sed "s/^>//g" | sort > ${dir}/$1/ref_ids.txt

        mapfile -t < ${dir}/${1}/ref_ids.txt
        nw_prune -v <(nw_topology -bI trees/${1}.nwk) "${MAPFILE[@]}" > ${dir}/${1}/backbone_ml.nwk

	TMP=`mktemp -t XXXXXXX.fa`
	TMP2=`mktemp -t XXXXXXX.fa`
	bin/faSomeRecords alignments/ffn/${1}.fasta ${dir}/${1}/ref_ids.txt  $TMP
	sed -i "s/-//g" $TMP

	#faSomeRecords /oasis/projects/nsf/uot138/balaban/btol/nuc_alignments/genes/${1}/aln.fasta queries.txt $TMP2
        #sed -i "s/-//g" $TMP2
	cat $TMP ffn/${1}.ffn > ${dir}/$1/backtranslate.fasta	
	
	rm $TMP $TMP2
        run_upp.py --molecule=amino -s ${dir}/$1/query.fasta -a ${dir}/${1}/ref.fa -t ${dir}/$1/backbone_ml.nwk -b ${dir}/$1/backtranslate.fasta -A 100 -d ${dir}/$1 -x $UPPCORES 2> ${dir}/$1/log.err > ${dir}/$1/log.out

	python3 scripts/remove_third_codon.py ${dir}/$1/output_backtranslated_alignment_masked.fasta ${dir}/$1/output_backtranslated_alignment_masked_nothird.fasta

	popd > /dev/null

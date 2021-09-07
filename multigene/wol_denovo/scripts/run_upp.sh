#! /usr/bin/env bash

# $1 gene
# $2 dir

source activate woldenovo
conda activate woldenovo

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
pushd $PROJ_DIR > /dev/null

export dir=$2
export UPPCORES=6 # 6 cores per upp job
export TMPDIR=/dev/shm
export TMP=$TMPDIR

	mkdir -p ${dir}/query_align/$1
        cp ${dir}/faa/${1}.fasta ${dir}/query_align/$1/query.fasta

        bin/faSomeRecords -exclude ${dir}/alignments/faa/${1}.fasta ${dir}/queries.txt ${dir}/query_align/$1/ref.fa
        grep ">" ${dir}/query_align/$1/ref.fa | sed "s/^>//g" | sort > ${dir}/query_align/$1/ref_ids.txt

        mapfile -t < ${dir}/query_align/${1}/ref_ids.txt
        nw_prune -v <(nw_topology -bI ${dir}/trees/genes/${1}.nwk) "${MAPFILE[@]}" > ${dir}/query_align/${1}/backbone_ml.nwk

	TMP=`mktemp -t XXXXXXX.fa`
	TMP2=`mktemp -t XXXXXXX.fa`
	bin/faSomeRecords ${dir}/alignments/ffn/${1}.fasta ${dir}/query_align/${1}/ref_ids.txt  $TMP
	sed -i "s/-//g" $TMP

	#faSomeRecords /oasis/projects/nsf/uot138/balaban/btol/nuc_alignments/genes/${1}/aln.fasta queries.txt $TMP2
        #sed -i "s/-//g" $TMP2
	cat $TMP ${dir}/ffn/${1}.fasta > ${dir}/query_align/$1/backtranslate.fasta
	
	rm $TMP $TMP2
        run_upp.py --molecule=amino -s ${dir}/query_align/$1/query.fasta -a ${dir}/query_align/${1}/ref.fa -t ${dir}/query_align/$1/backbone_ml.nwk -b ${dir}/query_align/$1/backtranslate.fasta -A 100 -d ${dir}/query_align/$1 -x $UPPCORES 2> ${dir}/query_align/$1/log.err > ${dir}/query_align/$1/log.out

	python3 scripts/remove_third_codon.py ${dir}/query_align/$1/output_backtranslated_alignment_masked.fasta ${dir}/query_align/$1/output_backtranslated_alignment_masked_nothird.fasta

	popd > /dev/null

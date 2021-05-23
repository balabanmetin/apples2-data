#!/bin/bash
# $1 = dir

dir=$1

conda activate rnasimvs
source activate rnasimvs
# infer backbone tree using fasttree (3 cores)
fasttree -nosupport -gtr -gamma -nt -log ${dir}/backbone_ml.log < ${dir}/ref.fa > ${dir}/backbone_ml.fasttree

# infer minimum evolution branch lengths using fasttree (1 cores)
fasttree -nosupport -nt -nome -noml -log ${dir}/backbone_me.log -intree ${dir}/backbone_ml.fasttree < ${dir}/ref.fa > ${dir}/backbone_me.fasttree

# create taxtastic for pplacer
taxit create -l rnasim -P ${dir}/taxtastic.refpkg --aln-fasta ${dir}/ref.fa --tree-stats ${dir}/backbone_ml.log --tree-file ${dir}/backbone_ml.fasttree

# create apples2 database
build_applesdtb.py -D -t ${dir}/backbone_me.fasttree -o ${dir}/apples2.dtb -s ${dir}/ref.fa -f 0.2 -T 1


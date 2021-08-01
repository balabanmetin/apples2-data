#! /usr/bin/env bash

source activate wolmeta
conda activate wolmeta

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
echo $PROJ_DIR
pushd $PROJ_DIR > /dev/null

export dir=$1

ALL=`nproc --all`
export TMPDIR=/dev/shm
export TMP=$TMPDIR

#
TMP=`mktemp -t XXXXXXX.fa`
while read sp; do echo $PROJ_DIR/query_align/$sp/output_backtranslated_alignment_masked_nothird.fasta; done < $dir/select.txt | paste -s -d ' ' |  xargs bin/catfasta2phyml.pl -f -c > $TMP
#
python scripts/dedupe.py $TMP $dir/concat_dedup.fa $dir/dupmap.txt
#
rm $TMP
#
TMP=`mktemp -t XXXXXXX.fa`
cat faa/*.faa | grep ">" | sed "s/^.//g" | sort | uniq > $TMP

bin/faSomeRecords $dir/concat_dedup.fa  $TMP $dir/query.fa
bin/faSomeRecords -exclude $dir/concat_dedup.fa $TMP $dir/ref.fa
rm $TMP

cp queries.txt $dir
cp astral.lpp.nwk $dir
#bin/faSomeRecords $dir/concat_dedup.fa  $dir/queries.txt $dir/query.fa
#bin/faSomeRecords -exclude $dir/concat_dedup.fa $dir/queries.txt $dir/ref.fa
scripts/reestimate_backbone.sh $dir
#

cp $dir/true_me.fasttree $dir/backbone.nwk

#paste -s -d ' ' queries.txt | xargs nw_prune true_me.fasttree > backbone.nwk
#
run_apples.py --version
run_apples.py -q $dir/query.fa -s $dir/ref.fa -t $dir/backbone.nwk -o $dir/apples.jplace -D -f 0.2 -b 25 -T 28 > $dir/apples.out 2> $dir/apples.err
#
rm $dir/apples.newick
gappa examine graft --jplace-path=$dir/apples.jplace --out-dir=$dir
#
scripts/measure.sh $dir $dir/apples.newick $dir/astral.lpp.nwk $dir/backbone.nwk 

popd

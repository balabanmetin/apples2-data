#! /usr/bin/env bash

#$1 dir

#source activate woldenovo
#conda activate woldenovo

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
echo $PROJ_DIR
pushd $PROJ_DIR > /dev/null

export dir=$1

run_apples.py --version
/usr/bin/time -o $dir/time.txt -f "%e,%M" run_apples.py -q $dir/query.fa -s $dir/ref.fa -t $dir/backbone.nwk -o $dir/apples.jplace -D -f 0.2 -b 25 -T 1 > $dir/apples.out 2> $dir/apples.err
#
rm $dir/apples.newick
gappa examine graft --jplace-path=$dir/apples.jplace --out-dir=$dir
#
scripts/measure.sh $dir $dir/apples.newick trees/astral.lpp.nwk $dir/backbone.nwk

popd

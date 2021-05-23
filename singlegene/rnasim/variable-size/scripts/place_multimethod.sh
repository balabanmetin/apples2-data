#!/bin/bash

# $1 = tool name
# $2 = directory where files are
dir=$2
CORES=1

source activate rnasimvs
conda activate rnasimvs

if [ "$1" == "apples2" ]; then
	mkdir -p $dir/$1
	run_apples.py -h > /dev/null
	/usr/bin/time -o $dir/$1/time.txt -f "%e\t%M" run_apples.py -q $dir/query.fa -a $dir/apples2.dtb -o $dir/$1/result.jplace -f 0.2 -b 25 -T $CORES > $dir/$1/log.out 2> $dir/$1/log.err
elif [ "$1" == "apples" ]; then
	mkdir -p $dir/$1
	python apples-1.2.0/run_apples.py -h > /dev/null
	/usr/bin/time -o $dir/$1/time.txt -f "%e\t%M" python apples-1.2.0/run_apples.py -q $dir/query.fa -s $dir/ref.fa -m FM -c MLSE -t $dir/backbone_me.fasttree -o $dir/$1/result.jplace -T $CORES > $dir/$1/log.out 2> $dir/$1/log.err
elif [ "$1" == "pplacer" ]; then
	mkdir -p $dir/$1
	pplacer -h 2> /dev/null
	/usr/bin/time -o $dir/$1/time.txt -f "%e\t%M" pplacer -c $dir/taxtastic.refpkg -j $CORES $dir/query.fa --timing --out-dir $dir/$1/ > $dir/$1/log.out 2> $dir/$1/log.err
	cp $dir/$1/query.jplace $dir/$1/result.jplace
elif [ "$1" == "epa-ng" ]; then
	mkdir -p $dir/$1
        epa-ng -h > /dev/null
	/usr/bin/time -o $dir/$1/time.txt -f "%e\t%M" epa-ng -s $dir/ref.fa -q $dir/query.fa -t $dir/backbone_ml.fasttree -m GTR+G -w $dir/$1/ -T $CORES --redo > $dir/$1/log.out 2> $dir/$1/log.err
	mv $dir/$1/epa_result.jplace $dir/$1/result.jplace
elif [ "$1" == "rappas" ]; then
	echo "rappas"
else
	echo "placement tool is not recognized. provide the name of the tool"
fi 
echo "Placement is completed. starting error measurement..."
scripts/measure.sh $dir $1


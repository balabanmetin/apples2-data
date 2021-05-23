#! /usr/bin/env bash

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

for i in 500 1000 5000 10000 50000 100000 200000; do
        for j in 0 1 2 3 4; do
		for k in apples2 apples pplacer epa-ng; do 
			echo $PROJ_DIR/scripts/place_multimethod.sh $k $PROJ_DIR/data/$i/$j
		done
        done
done

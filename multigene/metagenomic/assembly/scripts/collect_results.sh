#! /usr/bin/env bash

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

for i in 50 381; do
	$PROJ_DIR/scripts/numcopy.sh data/$i | sed "s/$/ $i/g"
done | sed "s/$/ assembly/g" | tr " " "," > results.csv


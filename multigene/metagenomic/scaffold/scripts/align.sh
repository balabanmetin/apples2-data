#! /usr/bin/env bash

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

while read gn; do 
	echo $PROJ_DIR/scripts/run_upp.sh $gn $PROJ_DIR/query_align/
done < select.txt

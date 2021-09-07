#! /usr/bin/env bash

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

for i in 1000 3000; do 
    while read gn; do 
        echo $PROJ_DIR/scripts/run_upp.sh $gn $i
    done < select.txt
done

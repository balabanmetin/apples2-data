#! /usr/bin/env bash

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

while read g; do 
    for i in 1000 3000; do 
        echo $PROJ_DIR/scripts/process_a_marker.sh $i $g
    done
done < select.txt


#! /usr/bin/env bash

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

for i in random; do 
    for j in 10 25 50; do
        for k in 1 2 3 4 5; do 
            echo $PROJ_DIR/scripts/place_a_replicate.sh $i/$j/$k/1000
        done
    done
done

for i in best; do
    for j in 10 25 50 381; do
        for k in 1; do
            echo $PROJ_DIR/scripts/place_a_replicate.sh $i/$j/$k/1000
        done
    done
done

#! /usr/bin/env bash

DIR=`pwd`

for c in best random ; do
        for i in 10 25 50 381; do
            for k in 1 2 3 4 5; do
                      cat $DIR/$c/$i/$k/1000/results_apples.csv | sed "s/$/\t$c\t$i/g"
        done
    done
done > best_random_accuracy.csv

for c in best random ; do
        for i in 10 25 50 381; do
            for k in 1 2 3 4 5; do 
            ln=`bin/simplifyfasta.sh $c/$i/$k/1000/query.fa | wc -L`
			  cat $DIR/$c/$i/1/1000/time.txt | sed "s/$/,$c,$i,$ln/g"
        done
    done
done > best_random_time_memory.csv

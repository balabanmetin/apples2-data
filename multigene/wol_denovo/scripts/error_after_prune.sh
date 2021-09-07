#!/bin/bash

for i in 50 381; do 

    
    for k in 3000; do
         mkdir -p $k/error_after_prune/$i
         nw_labels -I 1000/data/$i/apples.newick > $k/error_after_prune/$i/1000_ref_and_qry.txt
         nw_prune -v $k/data/$i/backbone.nwk `cat $k/error_after_prune/$i/1000_ref_and_qry.txt` > $k/error_after_prune/$i/backbone.nwk
         nw_prune -v $k/data/$i/apples.newick `cat $k/error_after_prune/$i/1000_ref_and_qry.txt` > $k/error_after_prune/$i/apples.newick
         scripts/measure.sh $k/error_after_prune/$i/  $k/error_after_prune/$i/apples.newick astral.lpp.nwk $k/error_after_prune/$i/backbone.nwk
    done
    for k in 1000; do
        mkdir -p $k/error_after_prune/$i
        cp $k/data/$i/results_apples.csv $k/error_after_prune/$i
    done
done  

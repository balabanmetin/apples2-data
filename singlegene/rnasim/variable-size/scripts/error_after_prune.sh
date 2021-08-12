#!/bin/bash

for i in 10000 100000; do
    for j in 0 1 2 3 4; do
        mkdir -p error_after_prune/$i/$j/
	
        nw_labels data/1000/$j/true_topo.tree > error_after_prune/$i/$j/1000_ref_and_qry.txt
    	nw_prune -v data/$i/$j/backbone_me.fasttree `cat error_after_prune/$i/$j/1000_ref_and_qry.txt` > error_after_prune/$i/$j/backbone.nwk
        for k in apples2; do
            echo error_after_prune/$i/$j/$k/
            mkdir -p error_after_prune/$i/$j/$k/
            nw_prune -v data/$i/$j/$k/result.newick `cat error_after_prune/$i/$j/1000_ref_and_qry.txt` > error_after_prune/$i/$j/$k/results.nwk
            scripts/measure_generic.sh error_after_prune/$i/$j/$k error_after_prune/$i/$j/$k/results.nwk data/1000/$j/true_topo.tree error_after_prune/$i/$j/backbone.nwk 
        done
    	for k in apples2; do
	    mkdir -p error_after_prune/1000/$j/$k
	    cp data/1000/$j/$k/result.csv error_after_prune/1000/$j/$k/results_results.csv
	 done
    done
done

for i in 1000 10000 100000; do 
	for j in 0 1 2 3 4; do 
		for k in apples2; do 
			cat error_after_prune/$i/$j/$k/results_results.csv | while read x y; do dv=`nw_distance -m p -s a data/$i/$j/true_topo.tree $y`; printf "$y\t$dv\t$x\t$i\t$j\t$k\n" 
			done ; 
		done; 
	done; 
done > error_after_prune/allresults.csv

#!/bin/bash
#$1 dir
#$2 method name

export dir=$1
export bbone=${dir}/backbone_ml.fasttree

source activate rnasimvs
conda activate rnasimvs 

# convert jplace to newick in order to calculate RF distance.
gappa examine graft --jplace-path ${dir}/$2/result.jplace --allow-file-overwriting --out-dir ${dir}/$2 > ${dir}/$2/gappa.out 2> ${dir}/$2/gappa.err
export plcd=${dir}/$2/result.newick
export metname=$2

export leaves=`mktemp -t leavesXXXXXX.txt`
export queries=${dir}/queries.txt
export truetopo=${dir}/true_topo.tree

nw_labels -I $bbone > $leaves

printf "" > ${dir}/${metname}/result.csv

f() {
        query=$1
        # apples
        tmp=`mktemp -t tmpXXXXXX.txt`
        simptr=`mktemp -t simptrXXXXXX.txt`
        comm -13 <(echo $query) <(sort $queries) > $tmp
	# tmp holds the namoe of queries other than $1 and present in placement tree $plcd
	# in order to measure RF for the query $1 we must remove all other queries from
	# the placement tree
        if [ -s $tmp ]
        then
            paste -s -d ' ' $tmp | xargs nw_prune $plcd > $simptr
            #mapfile -t < $tmp
            #nw_prune -v $plcd "${MAPFILE[@]}" > $simptr
        else
            cat $plcd > $simptr
        fi

        n1=`bin/compareTrees.missingBranch $truetopo $simptr -simplify | awk '{printf $2}'`
        n2=`bin/compareTrees.missingBranch $truetopo $bbone -simplify | awk '{printf $2}'` 
#        nw_labels $truetopo | wc -l
#        nw_labels $simptr| wc -l
#        nw_labels $bbone| wc -l
#        echo "==================="
       python -c "print (\"%d\t%s\" % ($n1-$n2, \"${query}\"))" >> ${dir}/${metname}/result.csv
       rm $tmp
       rm $simptr

}  
export -f f

xargs -P 1 -I@ bash -c 'f @' < $queries

rm $leaves

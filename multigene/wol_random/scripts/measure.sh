#!/bin/bash
#$1 dir
#$2 full placement tree
#$3 true tree
#$4 backbone tree



export dir=$1
export bbone=$4
export plcd=$2
ext=${plcd##*.}
export metname=`basename $plcd .$ext`

export leaves=`mktemp -t leavesXXXXXX.txt`
export queries=`mktemp -t queriesXXXXXX.txt`
export truetopo=`mktemp -t truetopoXXXXXX.txt`

tmp=`mktemp -t tmpXXXXXX.txt`

nw_labels -I $4 > $leaves

comm -23 <(nw_labels -I $plcd | sort) <(nw_labels -I $bbone | sort) > $queries

# gamma variable
#gamma="$(grep -F "alpha[0]" ${1} | awk '{print $2}')"

cat $leaves $queries > $tmp
mapfile -t < $tmp
nw_prune -v <(nw_topology -bI ${3}) "${MAPFILE[@]}" > $truetopo
rm $tmp

printf "" > ${dir}/results_${metname}.csv

f() {
        query=$1
        # apples
        tmp=`mktemp -t tmpXXXXXX.txt`
        simptr=`mktemp -t simptrXXXXXX.txt`
        comm -13 <(echo $query) <(sort $queries) > $tmp
        if [ -s $tmp ]
        then
            paste -s -d ' ' $tmp | xargs nw_prune $plcd > $simptr
            #mapfile -t < $tmp
            #nw_prune -v $plcd "${MAPFILE[@]}" > $simptr
        else
            cat $plcd > $simptr
        fi

        n1=`compareTrees.missingBranch <(nw_topology -bI $truetopo) $simptr -simplify | awk '{printf $2}'`
        n2=`compareTrees.missingBranch <(nw_topology -bI $truetopo) $bbone -simplify | awk '{printf $2}'` 
#        nw_labels $truetopo | wc -l
#        nw_labels $simptr| wc -l
#        nw_labels $bbone| wc -l
#        echo "==================="
       python -c "print (\"%d\t%s\" % ($n1-$n2, \"${query}\"))" >> ${dir}/results_${metname}.csv
       rm $tmp
       rm $simptr

  }  
  export -f f

  xargs -P 24  -I@ bash -c 'f @' < $queries

rm $leaves
rm $queries
rm $truetopo

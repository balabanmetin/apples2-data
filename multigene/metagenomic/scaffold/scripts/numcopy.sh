#! /usr/bin/env bash

# $1 dir


for i in `cat ${1}/select.txt`; do cat ffn/${i}.ffn; done | grep ">" | sed "s/^.//g" | sort | uniq -c | tr '_' '\t' | awk '{$1=$1;print}' | tr ' ' '\t' | sed "s/$/\t1/g" > ${1}/numcopy.txt


join -j1 -o1.2,1.3,1.4,2.2 <(<${1}/results_apples.csv awk '{print $2"-"$3" "$0}' | sort -k1,1) <(<${1}/numcopy.txt awk '{print $2"-"$3" "$0}' | sort -k1,1)


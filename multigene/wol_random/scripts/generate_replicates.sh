#! /usr/bin/env bash

export SELDIR=`mktemp -t -d XXXXXX`

grep ">" random/10/concat_dedup.fa | sed "s/^.//g" > $SELDIR/all.txt

for i in `seq 1 5`; do
	(echo $i; cat seed.txt) > $SELDIR/theseed.txt
	mkdir -p $SELDIR/$i/
	sort -R --random-source=$SELDIR/theseed.txt $SELDIR/all.txt | head -n 1000 > $SELDIR/$i/queries.txt
	for j in 1000; do
		mkdir -p $SELDIR/$i/$j/
		sort -R --random-source=$SELDIR/theseed.txt $SELDIR/all.txt | tail -n $j > $SELDIR/$i/$j/refseqs.txt
	done
done

f() {
	c=$1
    gn=$2
	i=$3
	j=$4
	mkdir -p $c/$gn/$i/$j
	cp $SELDIR/$i/queries.txt $c/$gn/$i/$j
	cp $SELDIR/$i/$j/refseqs.txt $c/$gn/$i/$j
	bin/faSomeRecords $c/$gn/concat_dedup.fa $c/$gn/$i/$j/queries.txt $c/$gn/$i/$j/query.fa
	bin/faSomeRecords $c/$gn/concat_dedup.fa $c/$gn/$i/$j/refseqs.txt $c/$gn/$i/$j/ref.fa
    scripts/reestimate_backbone.sh $c/$gn/$i/$j/ trees/astral.lpp.nwk 0
}

export -f f


for c in best; do
    for gn in 10 25 50 381; do
        for i in `seq 1`; do
            for j in 1000; do
                printf "f $c $gn $i $j \n"		
            done
        done
	done
done | xargs -n 1 -P 4 -t -I % bash -c "%"

for c in random; do
    for gn in 10 25 50; do
        for i in `seq 1 5`; do
            for j in 1000; do
                printf "f $c $gn $i $j \n"
            done
        done
    done
done | xargs -n 1 -P 4 -t -I % bash -c "%"


rm -rf $SELDIR



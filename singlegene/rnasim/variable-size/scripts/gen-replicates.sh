#! /usr/bin/env bash

#reproducible random number generator
get_seeded_random()
{
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}

# create replicate directories
mkdir -p data 

for i in 500 1000 5000 10000 50000 100000 200000; do
	for j in 0 1 2 3 4; do
		mkdir -p data/$i/$j
	done
done

mkdir -p tmp
# compute novelty for each sequence

bin/nw_distance -m p -s f -n  rnasim-source/true_topo.tree | sort -k2n > tmp/diversity.txt
pushd tmp
# this will create 20 quartiles with suffix 00 .. 19
split --lines=10000 -d diversity.txt diversity.
popd 

for i in 0 1 2 3 4; do
	for j in `seq -w 0 19`; do 
		# sort each quartile randomly with seed = replicate number
		# then select the top 10
		sort --random-source=<(get_seeded_random $i) -R tmp/diversity.${j} | head -n 10
	done | cut -f1 | sed "s/$/\t$j/g" > data/200000/$i/diversity_scores.txt
	cut -f1 data/200000/$i/diversity_scores.txt > data/200000/$i/queries.txt
	# create backboe and query alignment and backbone tree for 200000 subset
	bin/faSomeRecords rnasim-source/aln_dna.fa data/200000/$i/queries.txt  data/200000/$i/query.fa
	bin/faSomeRecords -exclude rnasim-source/aln_dna.fa data/200000/$i/queries.txt  data/200000/$i/ref.fa
	cp rnasim-source/true_topo.tree data/200000/$i/true_topo.tree
done 

# use same queries accross replicates with same id
for j in 0 1 2 3 4; do
	# shuffle backbone sequences using rep. id as seed
	# save it temporarily.
	grep ">" data/200000/$j/ref.fa | sed "s/^.//g" | sort --random-source=<(get_seeded_random $j) -R > tmp/refids.${j}
	for i in 500 1000 5000 10000 50000 100000 ; do
                cp data/200000/$j/queries.txt data/$i/$j
		cp data/200000/$j/query.fa data/$i/$j
		# use top $i ids in refid to subsample 200K alignment
		bin/faSomeRecords data/200000/$j/ref.fa <( head -n $i tmp/refids.${j}) data/$i/$j/ref.fa
		# prune true with 200K species to $i + 200  species
		bin/nw_prune -v data/200000/$j/true_topo.tree `(cat data/200000/$j/queries.txt; head -n $i tmp/refids.${j})` > data/$i/$j/true_topo.tree
        done
done


# create a conda environment including the tools benchmarked.
if conda info --envs | grep "rnasimvs" > /dev/null; then 
	echo "conda environment rnasimvs exists"
else
	conda create -y -c bioconda --name rnasimvs python=3.7 epa-ng=0.3.8 pip pplacer=1.1.alpha19 fasttree=2.1.10
	source activate rnasimvs
	conda activate rnasimvs
	pip install apples==2.0.2 taxtastic==0.9.1
	# fetch apples-1 release and extract
	wget https://github.com/balabanmetin/apples/archive/refs/tags/v1.2.0.tar.gz -P tmp
	tar -zxvf tmp/v1.2.0.tar.gz
fi

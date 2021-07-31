#! /usr/bin/env bash

#reproducible random number generator
get_seeded_random()
{
  seed="$1"
  openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
    </dev/zero 2>/dev/null
}


# create a conda environment including the tools benchmarked.
if conda info --envs | grep "wolmeta" > /dev/null; then 
	echo "conda environment wolmeta exists"
else
	mamba create -y -c bioconda --name wolmeta python=3.7 pip fasttree=2.1.10 gappa=0.7.1 newick_utils=1.6 setuptools
	source activate wolmeta
	conda activate wolmeta
	pip install apples==2.0.5
	# fetch apples-1 release and extract
	wget https://github.com/balabanmetin/apples/archive/refs/tags/v1.2.0.tar.gz -P tmp
	tar -zxvf tmp/v1.2.0.tar.gz

	# install pasta
	git clone https://github.com/smirarab/pasta.git
	git clone https://github.com/smirarab/sate-tools-linux.git
	# if osx replace the above line with the one below
	#git clone https://github.com/smirarab/sate-tools-mac.git
	pushd pasta
	python setup.py develop 
	popd
	# install sepp and upp 
	git clone https://github.com/smirarab/sepp.git
	pushd sepp
	python setup.py config
	python setup.py install
	python setup.py upp
	popd
	
fi

tar -Jxf faa.tar.xz
tar -Jxf ffn.tar.xz

# create replicate directories
mkdir -p data 
for i in 50 381; do
	mkdir -p data/$i
	head -n $i select.txt > data/$i/select.txt
	cp queries.txt data/$i/
done 

mkdir -p query_align

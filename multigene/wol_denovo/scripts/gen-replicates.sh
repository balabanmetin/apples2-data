#! /usr/bin/env bash

# create a conda environment including the tools benchmarked.
if conda info --envs | grep "woldenovo" > /dev/null; then
        echo "conda environment woldenovo exists"
else
        mamba create -y -c bioconda --channel smirarab --name woldenovo python=3.7 pip fasttree=2.1.10 gappa=0.7.1 newick_utils=1.6 setuptools raxml=8.2.10 iqtree=1.6.9 treeshrink=1.2.1 R=3.4.3
        source activate woldenovo
        conda activate woldenovo
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

git clone https://github.com/uym2/10kBacGenomes.git

for i in 1000 3000; do
    for j in faa ffn; do 
        mkdir -p $i/sequences/$j
        cat select.txt | while read gn; do 
            echo bin/faSomeRecords sequences/$j/$gn.fasta $i/refs.txt $i/sequences/$j/$gn.fasta
        done
    done
done | xargs -n1 -P32 -I% bash -c "%"


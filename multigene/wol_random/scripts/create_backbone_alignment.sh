#! /usr/bin/env bash

#reproducible random number generator
get_seeded_random()
{
      seed="$1"
        openssl enc -aes-256-ctr -pass pass:"$seed" -nosalt \
        </dev/zero 2>/dev/null
}

if conda info --envs | grep "wolrandom" > /dev/null; then
    echo "conda environment wolrandom exists"
else
    mamba create -y -c bioconda --name wolrandom python=3.7 pip fasttree=2.1.10 gappa=0.7.1 newick_utils=1.6 setuptools
    source activate wolrandom
    conda activate wolrandom
    pip install apples==2.0.5
fi

source activate wolrandom
conda activate wolrandom


# run from parent directory

for GN in 10 25 50 381; do
    for j in best random; do
        if [[ "$GN""$j" = "381random" ]]; then
            continue
        else
            mkdir -p $j/$GN/
            if [[ "$j" = "random" ]]; then
                sort --random-source=<(get_seeded_random $GN) -R qscores.txt | head -n $GN | cut -f1  > $j/$GN/select.txt
            else
                cat qscores.txt | sort -k2 | head -n $GN | cut -f1  > $j/$GN/select.txt
            fi

            # nuc concat second 
            TMP=`mktemp -t XXXXXXX.fa`
            TMP2=`mktemp -t XXXXXXX.fa`

            while read sp; do echo alignments/ffn/${sp}.fasta; done < $j/$GN/select.txt | paste -s -d ' ' |  xargs scripts/catfasta2phyml.pl -f -c > $TMP

            python3 scripts/remove_third_codon.py $TMP $TMP2

            python scripts/dedupe.py $TMP2 $j/$GN/concat_dedup.fa $j/$GN//dupmap.txt

            rm $TMP $TMP2

            fi
        done
    done

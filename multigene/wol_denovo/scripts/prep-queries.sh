#! /usr/bin/env bash
set -e

for size in 1000 3000; do
    export i=$size
    mkdir -p $i/{faa,ffn}
	mkdir -p $i/trees/genes/
    mkdir -p $i/alignments/{faa,ffn}
    #for g in p0309; do 
    #for g in `cat select.txt`; do 
    f() {
        g=$1
        cp $i/genes_processed/$g/bestTree.nwk $i/trees/genes/$g.nwk 
        faSomeRecords sequences/ffn/$g.fasta <(grep ">" $i/genes_processed/$g/UPPFAA_alignment.fasta | sed "s/>//g") $i/genes_processed/$g/UPPFFN_sequence.fasta
        python scripts/backtranslate.py $i/genes_processed/$g/UPPFAA_alignment.fasta $i/genes_processed/$g/UPPFFN_sequence.fasta > $i/genes_processed/$g/UPPFFN_alignment.fasta
		TMP=`mktemp -t XXXXXXX.fa`
		TMP2=`mktemp -t XXXXXXX.fa`
		COLNUM=`mktemp -t XXXXXXX.fa`
		python3 scripts/extract_codon.py $i/genes_processed/$g/UPPFFN_alignment.fasta $TMP 1
		# exctact first codon alignment (replace second and third codon positions with dashes)
		trimal -gt 0.05 -in $TMP -out $TMP2 -colnumbering > $COLNUM
		#choose least gappy ~1600 first codon positions. write indices of selected columns in a file
		grep "ColumnsMap" $COLNUM | sed 's/^.\{12\}//' | python3 scripts/codon_positions.py > $i/genes_processed/$g/select_cols.txt # for each selected forist codon index, add index +1 and index +2 to the list of selected columns. Write to a file
		trimal -selectcols `cat $i/genes_processed/$g/select_cols.txt` -complementary -in $i/genes_processed/$g/UPPFFN_alignment.fasta -out $i/genes_processed/$g/UPPFFN_alignment_trimmed.fasta
		python3 scripts/reduce_select_cols.py < $i/genes_processed/$g/select_cols.txt > $i/genes_processed/$g/select_cols_faa.txt      
		trimal -selectcols `cat $i/genes_processed/$g/select_cols_faa.txt` -complementary -in $i/genes_processed/$g/UPPFAA_alignment.fasta -out $i/genes_processed/$g/UPPFAA_alignment_trimmed.fasta
		rm $TMP $TMP2 $COLNUM
		faSomeRecords $i/genes_processed/$g/UPPFAA_alignment_trimmed.fasta <(nw_labels -I $i/trees/genes/$g.nwk) $i/alignments/faa/$g.fasta
		faSomeRecords $i/genes_processed/$g/UPPFFN_alignment_trimmed.fasta <(nw_labels -I $i/trees/genes/$g.nwk) $i/alignments/ffn/$g.fasta
		faSomeRecords sequences/faa/$g.fasta $i/queries.txt $i/faa/$g.fasta
		faSomeRecords sequences/ffn/$g.fasta $i/queries.txt $i/ffn/$g.fasta
	}
	export -f f
	cat select.txt | xargs -n1 -P24 -I% bash -c "f %" 
done

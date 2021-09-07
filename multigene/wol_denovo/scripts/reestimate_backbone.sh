#!/usr/bin/env bash

DIR=$1

TMP=`mktemp -t XXXXXXX.fa`
grep ">" $DIR/ref.fa | sed "s/^.//g" > $TMP
mapfile -t < $TMP
nw_prune -v <(nw_topology -bI $DIR/astral_mp.nwk) "${MAPFILE[@]}" > $DIR/topo_ref.tree


python3 scripts/resolve_polytomies.py $DIR/topo_ref.tree > $DIR/topo_ref_no_poly.tree

rm $TMP

export OMP_NUM_THREADS=1
bin/FastTreeMP  -nt -nosupport  -nome  -noml -log $DIR/true_me.fasttree.log -intree $DIR/topo_ref_no_poly.tree < $DIR/ref.fa > $DIR/true_me.fasttree



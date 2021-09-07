#!/bin/bash

export i=$1
export cores=$2

export PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

pushd $PROJ_DIR > /dev/null
    mkdir -p $i/trees
    cat $i/genes_processed/*/bestTree.nwk > $i/trees/astral_input.trees
    java -Xmx80G -D"java.library.path=ASTRAL/lib" -jar ASTRAL/astral.5.15.4.jar -T $cores -i $i/trees/astral_input.trees -o $i/trees/astral_mp.nwk > $i/trees/astral.out 2> $i/trees/astral.err
    
    
popd > /dev/null


#! /usr/bin/env bash
#$1 num threads

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

    for i in 1000 3000; do 
        echo $PROJ_DIR/scripts/build_st.sh $i $1
    done


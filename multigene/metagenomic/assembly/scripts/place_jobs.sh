#! /usr/bin/env bash

PROJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

for i in 50 381; do
	echo $PROJ_DIR/scripts/alt.sh data/$i
done


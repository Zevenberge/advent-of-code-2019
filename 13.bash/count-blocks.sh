#!/bin/bash
set -eo pipefail

AMOUNT_OF_ARGUMENTS=$#
echo "Got "$AMOUNT_OF_ARGUMENTS

i=0
blocks=0
#for i in {3..($AMOUNT_OF_ARGUMENTS+1)..3}
for arg in $*
do
    i=$(($i+1))
    if [ $(($i % 3)) -eq 0 ];
    then
        if [ $arg -eq 2 ]
        then
            blocks=$(($blocks+1))
        fi
    fi
done
echo "Amount of blocks: "$blocks
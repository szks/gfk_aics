#!/bin/bash

set -e -o pipefail

GFKDIR=$1
SHAREDDIR=$2
myrank=$3
sample=$4
thread=$5

. $GFKDIR/common.sh

num=`printf '%03d' $thread`

RUN_PERL $GFKDIR/makeComb2seq.pl $SHAREDDIR/comb2ID2.$sample.txt $myrank.sam > $SHAREDDIR/comb2seq.tmp.$sample.$num.txt

#rm -f $myrank.sam

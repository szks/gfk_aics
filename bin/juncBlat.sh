#!/bin/bash

set -e -o pipefail

GFKDIR=$1
SHAREDDIR=$2
myrank=$3
sample=$4
thread=$5

. $GFKDIR/common.sh

i=`expr ${thread} + 1`
region=`sed -n ${i}p $SHAREDDIR/interval_list.txt`

RUN $GFKDIR/samtools view -h -F 1024 $SHAREDDIR/GFKdedup.$sample.bam $region > $myrank.sam

RUN_PERL $GFKDIR/getCandJunc.pl $myrank.sam 20 16 > candJunc.$myrank.fa

RUN $GFKDIR/blat -stepSize=5 -repMatch=2253 -minScore=20 -ooc=$SHAREDDIR/11.ooc $SHAREDDIR/hg19.2bit candJunc.$myrank.fa candJunc.$myrank.psl

RUN python $GFKDIR/merge_psl.py $OMP_NUM_THREADS candJunc.$myrank.psl

#rm -f ./candJunc.$myrank.psl.*

num=`printf '%03d' $thread`

RUN_PERL $GFKDIR/psl2junction.pl ./candJunc.$myrank.psl $SHAREDDIR/countJunc.$sample.$num.txt $SHAREDDIR/junc2ID.$sample.$num.txt

#rm -f ./candJunc.$myrank.fa ./candJunc.$myrank.psl

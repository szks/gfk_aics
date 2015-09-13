#!/bin/bash

set -e -o pipefail

GFKDIR=$1
SHAREDDIR=$2
myrank=$3
align_dedup=$4

if [ "$PJM_RSCUNIT" = "gwmpc" ]  # HOKUSAI FX100
then
        if [ $align_dedup -eq 0 ]; then
                ln -s ../../Input/GFKOUTPUT.$myrank ./GFKOUTPUT
        fi
fi

. $GFKDIR/common.sh


para_sam2bam()
{
        sed -n -e 's/^@SQ\tSN://p' -e 's/LN://' ${SHAREDDIR}/hg19.header > header.txt
        num=`printf '%05d' $myrank`
        ls aligned_chr.* | xargs -t -P${OMP_NUM_THREADS} -I@ ${GFKDIR}/samtools view -Sbu -t header.txt -o ${SHAREDDIR}/@.${num}.bam @
}


RUN python ${GFKDIR}/split.py GFKOUTPUT aligned_chr

RUN para_sam2bam

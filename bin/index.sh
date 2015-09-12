#!/bin/bash

set -e -o pipefail

GFKDIR=$1
SHAREDDIR=$2
myrank=0

. $GFKDIR/common.sh

merge_bam() {
        sed -e 's/SO:unsorted/SO:coordinate/' ${SHAREDDIR}/hg19.header > header.txt
        ls ${SHAREDDIR}/deduped.*.bam | xargs ${GFKDIR}/samtools cat -h header.txt -o GFKdedup.0.bam
        #rm ${SHAREDDIR}/deduped.*.bam
}

RUN merge_bam
check_size GFKdedup.0.bam

RUN ${GFKDIR}/samtools index GFKdedup.0.bam
check_size GFKdedup.0.bam.bai

if [ "$PJM_RSCUNIT" = "gwmpc" ]  # HOKUSAI FX100
then
        ln -f GFKdedup.0.bam ../Output/GFKdedup.0.bam
        ln -f GFKdedup.0.bam.bai ../Output/GFKdedup.0.bam.bai
fi

#!/bin/bash

set -e -o pipefail

GFKDIR=$1
SHAREDDIR=$2
myrank=$3

. $GFKDIR/common.sh


num=`printf '%05d' $myrank`

cat_view_sort_rmdup() {
        ls ${SHAREDDIR}/aligned_chr.${myrank}.*.bam | \
        xargs ${GFKDIR}/samtools cat |
        ${GFKDIR}/samtools sort -m 1GB -@ ${OMP_NUM_THREADS} -o -l0 - dummy | \
        ${GFKDIR}/samtools rmdup -u - - | \
        ${GFKDIR}/samtools view -b -@ ${OMP_NUM_THREADS} - > ${SHAREDDIR}/deduped.${num}.bam
}


RUN cat_view_sort_rmdup
check_size ${SHAREDDIR}/deduped.${num}.bam

#rm ${SHAREDDIR}/aligned_chr.${myrank}.*.bam

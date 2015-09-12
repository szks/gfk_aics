#!/bin/bash

set -e -o pipefail

GFKDIR=$1
SHAREDDIR=$2
myrank=$3 

# HOKUSHAI
if [ "$PJM_RSCUNIT" = "gwmpc" -o  "$PJM_RSCUNIT" = "gwacsg" ]; then
        ln -s ../../Input/GFKINPUT1.$myrank GFKINPUT1
        ln -s ../../Input/GFKINPUT2.$myrank GFKINPUT2
fi

. $GFKDIR/common.sh


pre_blat()
{
        local p=$1
        RUN ${GFKDIR}/bowtie -a --best --strata -m 20 -v 3 -S ${SHAREDDIR}/knownGene GFKINPUT$p bowtie.tmp$p.sam
        RUN_PERL ${GFKDIR}/convert2GenomicCoordinate.pl bowtie.tmp$p.sam ${SHAREDDIR}/knownGene.info > temp$p
        RUN_PERL ${GFKDIR}/getUniqueReads.pl temp$p > bowtie$p.sam
        RUN_PERL ${GFKDIR}/gatherUnmappedIntoFa.pl bowtie.tmp$p.sam > unmapped$p.fa
}


psl2sam()
{
        local p=$1
        local i=0
        while [ $i -lt $OMP_NUM_THREADS ]
        do
                RUN_PERL $GFKDIR/test_psl2sam.pl blat$p.psl.$i ./blat 20 > blat$p.sam.$i &
                i=`expr $i + 1`
        done
        wait
}


post_blat()
{
        local p=$1
        RUN_PERL ${GFKDIR}/test_merge_sam.pl ${OMP_NUM_THREADS} blat$p.psl.index blat$p.sam unmapped$p.fa ./blat > blat$p.sam
        RUN_PERL ${GFKDIR}/merge_bowtie_blat.pl bowtie$p.sam blat$p.sam > aligned$p.sam
}


parallel_region1()
{
        pre_blat 1 &
        if [ "$TIMEFORMAT1" != "" ]; then
                local TIMEFORMAT=$TIMEFORMAT1
        else
                local TIME=""
        fi
        pre_blat 2 &
        wait
}


parallel_region2()
{
        post_blat 1 &
        if [ "$TIMEFORMAT1" != "" ]; then
                local TIMEFORMAT=$TIMEFORMAT1
        else
                local TIME=""
        fi
        post_blat 2 &
        wait
}


#pre blat
RUN parallel_region1

check_size unmapped1.fa
check_size unmapped2.fa

RUN ${GFKDIR}/blat -stepSize=5 -repMatch=2253 -ooc=${SHAREDDIR}/11.ooc ${SHAREDDIR}/hg19.2bit ./unmapped1.fa ./blat1.psl

RUN ${GFKDIR}/blat -stepSize=5 -repMatch=2253 -ooc=${SHAREDDIR}/11.ooc ${SHAREDDIR}/hg19.2bit ./unmapped2.fa ./blat2.psl

RUN psl2sam 1

RUN psl2sam 2

#post blat
RUN parallel_region2

RUN_PERL ${GFKDIR}/mateMerge.pl aligned1.sam aligned2.sam > GFKOUTPUT


# HOKUSHAI
if [ "$PJM_RSCUNIT" = "gwmpc" -o  "$PJM_RSCUNIT" = "gwacsg" ]; then
        ln -f GFKOUTPUT ../Output/GFKOUTPUT.$myrank
fi

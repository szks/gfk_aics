#!/bin/sh -x
#PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=44"
#PJM --mpi "proc=44"
#PJM --rsc-list "elapse=45:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=0 ./bin/* 0:../"
#PJM --stgin "rank=0 ./ref/*    0:../"
#PJM --stgin "rank=0 ./Input/GFKdedup.*.bam 0:../"
#PJM --stgin "rank=0 ./Input/GFKdedup.*.bam.bai 0:../"
#PJM --stgout "rank=* ./fusion.%r.txt ./Output/"
#PJM --stgout "rank=* ./out.%r %j/"
#PJM --stgout "rank=* ./err.%r %j/"
#PJM -S

t0=`date +%s`

. /work/system/Env_base

export OMP_NUM_THREADS=8
export XOS_MMM_L_ARENA_LOCK_TYPE=0

export TIMEFORMAT=$'time(real,user,sys) = %R\t%U\t%S'
export TIMEFORMAT1=$'> time(real,user,sys) = %R\t%U\t%S'
export TIMEFORMAT2=$'>> time(real,user,sys) = %R\t%U\t%S'

mpiexec  -ofout-proc out -oferr-proc err ../GFKdetect

t1=`date +%s`
t=`expr $t1 - $t0`
echo "" 1>&2
echo "Total time = $t" 1>&2

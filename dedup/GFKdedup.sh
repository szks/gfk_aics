#!/bin/sh -x
#PJM --rsc-list "rscgrp=large"
#PJM --rsc-list "node=624"
#PJM --mpi "proc=624"
#PJM --rsc-list "elapse=45:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=0 ./bin/*  ../"
#PJM --stgin "rank=0 ./ref/*  ../"
#PJM --stgin "rank=* ./Input/GFKOUTPUT.%r %r:./GFKOUTPUT"
#PJM --stgout "rank=0 ./GFKdedup.0.bam ./Output/"
#PJM --stgout "rank=0 ./GFKdedup.0.bam.bai ./Output/"
#PJM --stgout "rank=* ./out.%r %j/"
#PJM --stgout "rank=* ./err.%r %j/"
#PJM -S

t0=`date +%s`

. /work/system/Env_base

export OMP_NUM_THREADS=8

export TIMEFORMAT=$'time(real,user,sys) = %R\t%U\t%S'

mpiexec -ofout-proc out -oferr-proc err ../GFKdedup

t1=`date +%s`
t=`expr $t1 - $t0`
echo "" 1>&2
echo "Total time = $t" 1>&2

#!/bin/sh -x
#PJM --rsc-list "rscgrp=large"
#PJM --rsc-list "node=624"
#PJM --mpi "proc=624"
#PJM --rsc-list "elapse=1:00:00"
#PJM --stg-transfiles all
#PJM --mpi "use-rankdir"
#PJM --stgin "rank=0 ./bin/*    0:../"
#PJM --stgin "rank=0 ./ref/*    0:../"
#PJM --stgin "rank=* ./Input/GFKINPUT1.%r %r:./GFKINPUT1"
#PJM --stgin "rank=* ./Input/GFKINPUT2.%r %r:./GFKINPUT2"
#PJM --stgout "rank=* ./GFKOUTPUT ./Output/GFKOUTPUT.%r"
#PJM --stgout "rank=* ./out.%r %j/"
#PJM --stgout "rank=* ./err.%r %j/"
#PJM -S

t0=`date +%s`

. /work/system/Env_base

export OMP_NUM_THREADS=8
export XOS_MMM_L_ARENA_LOCK_TYPE=0

export TIMEFORMAT=$'time(real,user,sys) = %R\t%U\t%S'
export TIMEFORMAT1=$'> time(real,user,sys) = %R\t%U\t%S'

mpiexec -ofout-proc out -oferr-proc err ../GFKalign

t1=`date +%s`
t=`expr $t1 - $t0`
echo "" 1>&2
echo "Total time = $t" 1>&2

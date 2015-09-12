#!/bin/sh -x
#PJM -L rscunit=gwmpc
#PJM -L rscgrp=batch
#PJM -L node=11
#PJM --mpi proc=44
#PJM -L elapse=1:00:00
#PJM -g G15026
#PJM -S

t0=`date +%s`

mkdir ${PJM_JOBID}
cd ${PJM_JOBID}
ln -s ../Output .
mkdir bin shared
for file in ../bin/*
do
        ln -sf `readlink -e $file` bin/
done
for file in ../ref/*
do
        ln -sf `readlink -e $file` shared/
done
ln -sf `readlink -e ../Input/GFKdedup.0.bam` shared/
ln -sf `readlink -e ../Input/GFKdedup.0.bam.bai` shared/

export OMP_NUM_THREADS=8

export XOS_MMM_L_ARENA_FREE=1
export XOS_MMM_L_ARENA_LOCK_TYPE=0

export TIMEFORMAT=$'time(real,user,sys) = %R\t%U\t%S'
export TIMEFORMAT1=$'> time(real,user,sys) = %R\t%U\t%S'
export TIMEFORMAT2=$'>> time(real,user,sys) = %R\t%U\t%S'

mpiexec -ofout-proc out -oferr-proc err ./bin/GFKdetect

t1=`date +%s`
t=`expr $t1 - $t0`
echo "" 1>&2
echo "Total time = $t" 1>&2


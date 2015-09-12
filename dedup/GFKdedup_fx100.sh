#!/bin/sh
#PJM -L rscunit=gwmpc
#PJM -L rscgrp=batch
#PJM -L node=156
#PJM --mpi proc=624
#PJM -L elapse=30:00
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

export OMP_NUM_THREADS=8

export TIMEFORMAT=$'time(real,user,sys) = %R\t%U\t%S'

mpiexec -ofout-proc out -oferr-proc err ./bin/GFKdedup

t1=`date +%s`
t=`expr $t1 - $t0`
echo "" 1>&2
echo "Total time = $t" 1>&2

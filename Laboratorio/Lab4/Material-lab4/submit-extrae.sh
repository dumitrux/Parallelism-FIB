#!/bin/bash
### Directives pel gestor de cues
# following option makes sure the job will run in the current directory
#$ -cwd
# following option makes sure the job has the same environmnent variables as the submission shell
#$ -V
# Canviar el nom del job
#$ -N lab1-extrae
# Per canviar de shell
#$ -S /bin/bash

USAGE="\n USAGE: ./run-omp.sh prog size cutoff num_threads\n
        prog        -> omp program name\n
        size        -> chessboard size\n
        cutoff      -> recursion cutoff level\n
        num_threads -> number of threads\n"

if (test $# -lt 4 || test $# -gt 4)
then
	echo -e $USAGE
        exit 0
fi

make $1

HOST=$(echo $HOSTNAME | cut -f 1 -d'.')

export OMP_NUM_THREADS=$4

export LD_PRELOAD=${EXTRAE_HOME}/lib/libomptrace.so

./$1 -n$2 -c$3
unset LD_PRELOAD
mpi2prv -f TRACE.mpits -o $1-$2-$3-$4-${HOST}.prv -e $1 -paraver

#!/bin/bash

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

export OMP_NUM_THREADS=$4
export OMP_NESTED=TRUE

/usr/bin/time ./$1 -n$2 -c$3

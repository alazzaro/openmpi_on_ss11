#!/bin/bash -l

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

source ../sourceme_craympi.sh

APP=xthi

cc -g -fopenmp -o ${APP}_craympi.c.x ${APP}.c
srun -c $OMP_NUM_THREADS ../select_gpu.sh ./${APP}_craympi.c.x | sort -n -k 4 -k 6

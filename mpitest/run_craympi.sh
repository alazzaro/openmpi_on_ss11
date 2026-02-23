#!/bin/bash -l

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

source ../sourceme_craympi.sh

APP=mpitest

cc -g -o ${APP}_craympi.c.x ${APP}.c
srun ./${APP}_craympi.c.x
ftn -g -o ${APP}_craympi.f90.x ${APP}.f90
srun ./${APP}_craympi.f90.x

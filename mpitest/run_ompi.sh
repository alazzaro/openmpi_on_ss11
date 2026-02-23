#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

source ../sourceme_ompi.sh

cd $SCRIPT_DIR

# OFI env
export FI_LNX_PROV_LINKS="shm+cxi"
export FI_SHM_USE_XPMEM=1

# OpenMPI env
export OMPI_MCA_mtl=ofi
export OMPI_MCA_opal_common_ofi_provider_include="shm+cxi:lnx"
export OMPI_MCA_smsc=xpmem

APP=mpitest

mpicc -g -o ${APP}_ompi.c.x ${APP}.c
mpirun ./${APP}_ompi.c.x
mpifort -g -o ${APP}_ompi.f90.x ${APP}.f90
mpirun ./${APP}_ompi.f90.x

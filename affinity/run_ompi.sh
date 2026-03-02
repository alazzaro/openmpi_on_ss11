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

APP=xthi

# Take all GPUs
RUN_COMMAND="mpirun --bind-to core --map-by L3cache:pe=${OMP_NUM_THREADS} --mca hwloc_base_binding_policy core --mca hwloc_base_mem_bind policy:bind ../select_gpu.sh"
# Take only 2 GPUs
#RUN_COMMAND="mpirun --bind-to numa --map-by numa --mca hwloc_base_binding_policy core --mca hwloc_base_mem_bind policy:bind ../select_gpu.sh"

mpicc -g -fopenmp -o ${APP}_ompi.c.x ${APP}.c
${RUN_COMMAND} ./${APP}_ompi.c.x | sort -n -k 4 -k 6

# Run hpcat, if present
if [ -d hpcat/install/share/modulefiles ]; then
    module use hpcat/install/share/modulefiles
    module load hpcat
    ${RUN_COMMANDS} hpcat -c --no-banner
fi

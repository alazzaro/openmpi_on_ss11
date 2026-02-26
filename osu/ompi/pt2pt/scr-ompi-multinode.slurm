#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=1 --nodes=2 --ntasks-per-node=1 --cpus-per-task=72
#SBATCH --time=0:30:00

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export OUTPUT_DIR=$SLURM_SUBMIT_DIR
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR

if [ "$OSU_ARGS" == "" ];then
    OSU_ARGS=" -c "
fi

source $ROOT_DIR/sourceme_ompi.sh

# with LinkX
export FI_SHM_USE_XPMEM=1
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_PROVIDER=lnx
export FI_LNX_PROV_LINKS=shm+cxi # changed in the binding script
export OMPI_MCA_opal_common_ofi_provider_include=lnx
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2

CMDS=("osu_bibw -b multiple D D" "osu_latency D D" "osu_bibw -b multiple H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    run_osu_cmd "$cmd" "mpi/pt2pt" "_multinode_lnx"
done

# no OpenMPI internal transport, only libfabric. Use CXI directly
export FI_SHM_USE_XPMEM=1
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_PROVIDER=cxi
unset FI_LNX_PROV_LINKS
export OMPI_MCA_opal_common_ofi_provider_include=cxi
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2

CMDS=("osu_bibw -b multiple D D" "osu_latency D D" "osu_bibw -b multiple H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    run_osu_cmd "$cmd" "mpi/pt2pt" "_multinode_cxi"
done

# NCCL
source $ROOT_DIR/sourceme_nccl.sh

CMDS=("osu_xccl_bibw -b multiple D D" "osu_xccl_latency D D")
for cmd in "${CMDS[@]}"; do
    run_osu_cmd "$cmd" "xccl/pt2pt" "_multinode"
done

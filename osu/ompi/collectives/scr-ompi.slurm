#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=4 --ntasks-per-node=4 --cpus-per-task=72
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
#export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

# with LinkX
export FI_SHM_USE_XPMEM=1
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_PROVIDER=lnx
export FI_LNX_PROV_LINKS=shm+cxi
export OMPI_MCA_opal_common_ofi_provider_include=lnx
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2

CMDS=("osu_alltoall D D" "osu_allreduce D D" "osu_allgather D D" "osu_alltoall H H" "osu_allreduce H H" "osu_allgather H H")
for cmd in "${CMDS[@]}"; do
    run_osu_cmd "$cmd" "mpi/collective" "_n${SLURM_NTASKS}_lnx"
done

# with OpenMPI internal transport
if [ "$SLURM_NNODES" == "1" ]; then
    unset FI_SHM_USE_XPMEM
    unset FI_PROVIDER
    unset FI_CXI_RX_MATCH_MODE
    unset FI_LNX_PROV_LINKS
    unset OMPI_MCA_opal_common_ofi_provider_include
    unset OMPI_MCA_mtl_ofi_av
    export OMPI_MCA_pml=ob1
    export OMPI_MCA_btl=vader,smcuda,self
    unset OMPI_MCA_mtl
    export PRTE_MCA_ras_base_launch_orted_on_hn=1
    export PMIX_MCA_gds=^shmem2

    CMDS=("osu_alltoall D D" "osu_allreduce D D" "osu_allgather D D" "osu_alltoall H H" "osu_allreduce H H" "osu_allgather H H")
    for cmd in "${CMDS[@]}"; do
	run_osu_cmd "$cmd" "mpi/collective" "_n${SLURM_NTASKS}_ob1"
    done
else
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

    CMDS=("osu_alltoall D D" "osu_allreduce D D" "osu_allgather D D" "osu_alltoall H H" "osu_allreduce H H" "osu_allgather H H")
    for cmd in "${CMDS[@]}"; do
	run_osu_cmd "$cmd" "mpi/collective" "_n${SLURM_NTASKS}_cxi"
    done
fi

# NCCL
source $ROOT_DIR/sourceme_nccl.sh

# recommended settings
export HSA_FORCE_FINE_GRAIN_PCIE=1
export FI_MR_CACHE_MONITOR=kdreg2
export FI_CXI_DISABLE_HOST_REGISTER=1
export FI_CXI_DEFAULT_CQ_SIZE=131072
export FI_CXI_RDZV_PROTO=alt_read
export FI_CXI_RDZV_EAGER_SIZE=0
export FI_CXI_DEFAULT_TX_SIZE=2048
#export NCCL_CROSS_NIC=1
export NCCL_NET_GDR_LEVEL=PHB
#export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_NET="AWS Libfabric"

CMDS=("osu_xccl_alltoall" "osu_xccl_allreduce" "osu_xccl_allgather")
for cmd in "${CMDS[@]}"; do
    run_osu_cmd "$cmd" "xccl/collective" "_n${SLURM_NTASKS}"
done

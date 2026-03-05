#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=4 --ntasks-per-node=4 --cpus-per-task=72
#SBATCH --time=0:30:00

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export OUTPUT_DIR=$SLURM_SUBMIT_DIR
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR
source $ROOT_DIR/sourceme_craympi.sh

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=XPMEM
#export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

export FI_CXI_RX_MATCH_MODE=hybrid
export FI_CXI_RDZV_EAGER_SIZE=1024
export FI_CXI_RDZV_THRESHOLD=65536 # has to be 64k for nccl allgather to perform well

CMDS=("osu_alltoall -d cuda" "osu_allreduce -d cuda" "osu_allgather -d cuda" "osu_allreduce" "osu_alltoall" "osu_allgather")
for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_n"${SLURM_NTASKS}".txt"
    echo -- srun $cmd
    srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/mpi/collective/$cmd | tee $OUTPUT_DIR/$logname
done

# NCCL
source $ROOT_DIR/sourceme_nccl.sh

export MPICH_GPU_SUPPORT_ENABLED=0

# recommended settings
export HSA_FORCE_FINE_GRAIN_PCIE=1
export FI_MR_CACHE_MONITOR=kdreg2
export FI_CXI_DISABLE_HOST_REGISTER=1
export FI_CXI_DEFAULT_CQ_SIZE=131072
export FI_CXI_RDZV_PROTO=alt_read
#export FI_CXI_RDZV_EAGER_SIZE=0
export FI_CXI_DEFAULT_TX_SIZE=2048
#export NCCL_CROSS_NIC=1
export NCCL_NET_GDR_LEVEL=PHB
#export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3
export NCCL_NET="AWS Libfabric"

CMDS=("osu_xccl_alltoall" "osu_xccl_allreduce" "osu_xccl_allgather")
for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_n"${SLURM_NTASKS}".txt"
    echo -- srun $cmd
    srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/xccl/collective/$cmd | tee $OUTPUT_DIR/$logname
done

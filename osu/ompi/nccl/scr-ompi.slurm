#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=4 --ntasks-per-node=4 --cpus-per-task=72
#SBATCH --time=0:30:00

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export OUTPUT_DIR=$SLURM_SUBMIT_DIR
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR

source $ROOT_DIR/sourceme_ompi.sh
#export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

# NCCL tests
source $ROOT_DIR/sourceme_nccl.sh
#ml use /cluster/home/marcink/modules/
#ml load nccl/ryan_nccl_fix
#ml load libfabric/ryan_nccl_fix
#export LD_PRELOAD=/cluster/projects/nn9999k/marcink/software/libfabric/ryan_nccl_fix/lib/libfabric.so
ml list

# recommended settings
export HSA_FORCE_FINE_GRAIN_PCIE=1
export FI_MR_CACHE_MONITOR=kdreg2
export FI_CXI_DISABLE_HOST_REGISTER=1
export FI_CXI_DEFAULT_CQ_SIZE=131072
export FI_CXI_RDZV_PROTO=alt_read
export FI_CXI_DEFAULT_TX_SIZE=2048
#export NCCL_CROSS_NIC=1
export NCCL_NET_GDR_LEVEL=PHB
#export NCCL_SOCKET_IFNAME=hsn3
export NCCL_NET="AWS Libfabric"

# tuning
export FI_CXI_RDZV_EAGER_SIZE=1024 # has to be 4k+
export FI_CXI_RDZV_THRESHOLD=65536 # has to be 32k for osu nccl allgather to perform well
                                   # also has some positive effect on allreduce

# NCCL or nccl-tests don't work with OpenMPI OFI turned on,
# or at least not when it uses HMEM. So one of the below is necessary:
export OMPI_MCA_pml=ob1
export OMPI_MCA_btl=tcp,sm,self
export OMPI_MCA_btl_tcp_if_include=bond0
unset FI_PROVIDER
export OMPI_MCA_mtl_ofi_disable_hmem=true
#export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

# mkdir ${SLURM_JOB_ID}
CMDS=("all_gather_perf" "all_reduce_perf" "alltoall_perf")
for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_n"${SLURM_NTASKS}".txt"
    echo -- srun $cmd
    mpirun -map-by numa -bind-to numa ~/src/nccl/nccl-tests-2.17.9/build-ompi/$cmd -d uint8 -b 1 -e 128M -f 2 -g 1 | tee ${OUTPUT_DIR}/$logname
    # srun --cpu-bind=verbose,cores ~/src/libfabric_master/nccl-tests-2.17.9/build/$cmd -d uint8 -b 1 -e 128M -f 2 -g 1 | tee ${OUTPUT_DIR}/$logname
done

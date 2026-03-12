#!/bin/bash
#SBATCH --job-name=nccl-bench
#SBATCH --nodes=2
#SBATCH --gpus=8
#SBATCH --time=00:15:00
#SBATCH --exclusive
#SBATCH --output=out/nccl-bench-%j-opt.out

BW_BIN=/projects/public/vendor/jessj01.vendor/libfabric-tuning/benchmark/osu-7.5.2/libexec/osu-micro-benchmarks/nccl/pt2pt/osu_xccl_bibw
LATENCY_BIN=/projects/public/vendor/jessj01.vendor/libfabric-tuning/benchmark/osu-7.5.2/libexec/osu-micro-benchmarks/nccl/pt2pt/osu_xccl_latency

module reset
module load libfabric
module list

echo "WITH OPTIMIZATION"
# Use aws-ofi-nccl
export LD_LIBRARY_PATH="/tools/brics/apps/linux-sles15-neoverse_v2/gcc-12.3.0/aws-ofi-nccl-1.8.1-c47cd5ivrugm3jzlyqyis4igyflnydmo/lib:$LD_LIBRARY_PATH"
export NCCL_NET="AWS Libfabric"
# Use the high speed network interface
export NCCL_SOCKET_IFNAME="hsn"
# Print the NCCL version at startup
export NCCL_DEBUG="VERSION"
# Use P2P when GPUs are on the same NUMA node.
export NCCL_NET_GDR_LEVEL="PHB"
# Allow rings/trees to use different NICs due to Slingshot topology.
export NCCL_CROSS_NIC="1"
export NCCL_MIN_NCHANNELS="4"
export NCCL_GDRCOPY_ENABLE="1"

# FI (libfabric) environment variables to optimise NCCL on Slingshot
export FI_CXI_DEFAULT_CQ_SIZE="131072"
export FI_CXI_DEFAULT_TX_SIZE="1024"
export FI_CXI_DISABLE_NON_INJECT_MSG_IDC="1"
export FI_HMEM_CUDA_USE_GDRCOPY="1"
# Setting the cache monitor and host register prevents NCCL hangs / deadlocks
export FI_CXI_DISABLE_HOST_REGISTER="1"
export FI_MR_CACHE_MONITOR="userfaultfd"
# Further optimisation with the alternative rendezvous protocol
export FI_CXI_RDZV_PROTO="alt_read"
export FI_CXI_RDZV_THRESHOLD="0"
export FI_CXI_RDZV_GET_MIN="0"
export FI_CXI_RDZV_EAGER_SIZE="0"

# Execute benchmarks on 2 nodes
srun \
    --nodes=2 \
    --ntasks=2 \
    --gpus=2 \
    --cpus-per-task=12 \
    --ntasks-per-node=1 \
    $BW_BIN -b multiple -d cuda D D 

srun \
    --nodes=2 \
    --ntasks=2 \
    --gpus=2 \
    --cpus-per-task=12 \
    --ntasks-per-node=1 \
    $LATENCY_BIN -d cuda D D


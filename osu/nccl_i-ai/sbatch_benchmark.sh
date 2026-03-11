#!/bin/bash
#SBATCH --job-name=nccl-bench
#SBATCH --nodes=2
#SBATCH --gpus=8
#SBATCH --time=00:15:00
#SBATCH --exclusive
#SBATCH --output=out/nccl-bench-%j.out

BW_BIN=/projects/public/vendor/jessj01.vendor/libfabric-tuning/benchmark/osu-7.5.2/libexec/osu-micro-benchmarks/nccl/pt2pt/osu_xccl_bibw
LATENCY_BIN=/projects/public/vendor/jessj01.vendor/libfabric-tuning/benchmark/osu-7.5.2/libexec/osu-micro-benchmarks/nccl/pt2pt/osu_xccl_latency

module reset
module load libfabric
module list

echo "WITHOUT OPTIMIZATION"

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


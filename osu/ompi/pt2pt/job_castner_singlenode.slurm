#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=72
#SBATCH --gpus-per-node=2 
#SBATCH -p blancapeak
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o castner-slurm-%j-p2p_1N.out
#SBATCH --time=0:30:00

# Select 2 GPUs
export GPUSID="0 1"
export USE_SRUN=0

./run_singlenode.sh

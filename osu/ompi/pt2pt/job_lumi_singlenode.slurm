#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=2
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o lumi-slurm-%j-p2p_1N.out
#SBATCH --time=0:30:00

# Select 2 GPUs
export GPUSID="4 2"

./run_singlenode.sh

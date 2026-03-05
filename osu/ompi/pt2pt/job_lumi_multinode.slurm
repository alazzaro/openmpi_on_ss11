#!/bin/bash
#SBATCH -N 2
#SBATCH --ntasks-per-node=1
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o lumi-slurm-%j-p2p_2N.out
#SBATCH --time=0:20:00

./run_multinode.sh

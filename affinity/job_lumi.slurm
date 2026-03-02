#!/bin/bash
# Take all GPUs
#SBATCH -N 2
#SBATCH --ntasks-per-node=8
# Take only 2 GPUs
 ##SBATCH -N 1
 ##SBATCH --ntasks-per-node=2
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --hint=nomultithread
#SBATCH --network=single_node_vni

export OMP_PROC_BIND=close
export OMP_PLACES=cores
export OMP_NUM_THREADS=7
#export OMP_NUM_THREADS=1

./run_ompi.sh

./run_craympi.sh

#!/bin/bash
#SBATCH -N 2
#SBATCH --ntasks-per-node=8
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --hint=nomultithread
#SBATCH --network=single_node_vni

export OMP_PROC_BIND=close
export OMP_PLACES=cores
export OMP_NUM_THREADS=7

./run_ompi.sh

./run_craympi.sh

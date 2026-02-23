#!/bin/bash
#SBATCH -n 4
#SBATCH --ntasks-per-node=2
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --network=single_node_vni

./run_ompi.sh

./run_craympi.sh

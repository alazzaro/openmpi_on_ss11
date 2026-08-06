#!/bin/bash
#SBATCH -N 2
#SBATCH --ntasks-per-node=1
#SBATCH -p blancapeak
#SBATCH --exclusive
#SBATCH -o castner-slurm-%j-p2p_2N.out
#SBATCH --time=0:30:00

export USE_SRUN=0

./run_multinode.sh

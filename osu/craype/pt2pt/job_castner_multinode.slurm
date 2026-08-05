#!/bin/bash
#SBATCH -N 2
#SBATCH --ntasks-per-node=1
#SBATCH -p blancapeak
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o castner-slurm-%j-p2p_2N.out
#SBATCH --time=0:30:00

export MPICH_OFI_NIC_POLICY=GPU
./run_multinode.sh

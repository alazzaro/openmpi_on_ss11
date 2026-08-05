#!/bin/bash
#SBATCH -N 1
#SBATCH --ntasks-per-node=2
#SBATCH -p blancapeak
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o castner-slurm-%j-p2p_1N.out
#SBATCH --time=0:30:00

# Select 2 GPUs
export MPICH_OFI_NIC_POLICY=GPU
export SLURM_CPUS_PER_TASK=72
export GPUSID="0 1"

srun -n 1 nvidia-smi topo -m

./run_singlenode.sh

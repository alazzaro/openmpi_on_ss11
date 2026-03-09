#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=8 --ntasks-per-node=8 --cpus-per-task=7
#SBATCH --time=1:30:00
env | grep SLURM

ml swap PrgEnv-cray PrgEnv-gnu
ml load craype-accel-amd-gfx90a
ml use /users/makrotki/software/modules
ml load openmpi/5.0.8
ml list

export FI_CXI_RDZV_EAGER_SIZE=4096 # not so important, just large enough
export FI_CXI_RDZV_THRESHOLD=4096 # has to be 4k for cray mpi alltoall to loose a bump

# this is necessary for device collectives to work on NVIDIA. Otherwise segfault.
# export OMPI_MCA_mtl_ofi_disable_hmem=1

GPUBIND=~/cug_2026/select_gpu.sh
PREFIX=/scratch/project_465002282/marcink/software/osu-ompi/libexec/osu-micro-benchmarks/mpi/collective/

# with LinkX
export FI_SHM_USE_XPMEM=1
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_PROVIDER=lnx
export FI_LNX_PROV_LINKS=shm+cxi
export OMPI_MCA_opal_common_ofi_provider_include=lnx
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2
export FI_SHM_USE_XPMEM=0
export FI_CXI_RX_MATCH_MODE=hybrid
env | grep FI_

ml swap openmpi/5.0.8
ml list
ldd ${PREFIX}/osu_allreduce
VER=508
mkdir -p ${SLURM_NTASKS}/${VER}
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allreduce -d rocm | tee ${SLURM_NTASKS}/${VER}/osu_allreduce_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allgather -d rocm | tee ${SLURM_NTASKS}/${VER}/osu_allgather_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_alltoall -d rocm  | tee ${SLURM_NTASKS}/${VER}/osu_alltoall_d_rocm_${FI_PROVIDER}.txt

ml swap openmpi/5.0.9
ml list
ldd ${PREFIX}/osu_allreduce
VER=509
mkdir -p ${SLURM_NTASKS}/${VER}
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allreduce -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_allreduce_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allgather -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_allgather_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_alltoall -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_alltoall_d_rocm_${FI_PROVIDER}.txt


# with cxi
export FI_SHM_USE_XPMEM=1
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_PROVIDER=cxi
export FI_LNX_PROV_LINKS=shm+cxi
export OMPI_MCA_opal_common_ofi_provider_include=cxi
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2
export FI_SHM_USE_XPMEM=0
export FI_CXI_RX_MATCH_MODE=hybrid
env | grep FI_

ml swap openmpi/5.0.8
ml list
ldd ${PREFIX}/osu_allreduce
VER=508
mkdir -p ${SLURM_NTASKS}/${VER}
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allreduce -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_allreduce_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allgather -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_allgather_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_alltoall -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_alltoall_d_rocm_${FI_PROVIDER}.txt

ml swap openmpi/5.0.9
ml list
ldd ${PREFIX}/osu_allreduce
VER=509
mkdir -p ${SLURM_NTASKS}/${VER}
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allreduce -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_allreduce_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_allgather -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_allgather_d_rocm_${FI_PROVIDER}.txt
mpirun -map-by numa -bind-to numa ${GPUBIND} ${PREFIX}/osu_alltoall -d rocm | tee  ${SLURM_NTASKS}/${VER}/osu_alltoall_d_rocm_${FI_PROVIDER}.txt

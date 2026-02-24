#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=1 --nodes=2 --ntasks-per-node=1 --cpus-per-task=72
#SBATCH --time=0:10:00

ml reset
ml load NRIS/GPU 
ml load OpenMPI/5.0.9-GCC-14.3.0
ml list

export OSU_HOME=/cluster/projects/nn9999k/marcink/software/osu-eb/libexec/osu-micro-benchmarks/
export GPUBIND=/cluster/home/marcink/hpe_cug_paper/gpubind.sh

# with LinkX
export PMIX_MCA_gds=^shmem2
export FI_SHM_USE_XPMEM=1
export FI_PROVIDER=lnx
export FI_CXI_RX_MATCH_MODE=hybrid
export FI_LNX_PROV_LINKS=shm+cxi
export OMPI_MCA_opal_common_ofi_provider_include=lnx
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1

CMDS=("osu_bibw -W 64 D D" "osu_bibw -W 1 D D" "osu_latency D D" "osu_bibw -W 64 H H" "osu_bibw -W 1 H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_multinode_lnx_srun.txt"
    echo -- srun $cmd
    srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $logname
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_multinode_lnx_mpirun.txt"
    echo -- mpirun $cmd
    mpirun -bind-to core -map-by numa --report-bindings $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $logname
done

# no OpenMPI internal transport, only libfabric. Use CXI directly
export PMIX_MCA_gds=^shmem2
export FI_SHM_USE_XPMEM=1
export FI_PROVIDER=cxi
export FI_CXI_RX_MATCH_MODE=hybrid
unset FI_LNX_PROV_LINKS
export OMPI_MCA_opal_common_ofi_provider_include=cxi
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1

CMDS=("osu_bibw -W 64 D D" "osu_bibw -W 1 D D" "osu_latency D D" "osu_bibw -W 64 H H" "osu_bibw -W 1 H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_multinode_cxi_srun.txt"
    echo -- srun $cmd
    srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $logname
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_multinode_cxi_mpirun.txt"
    echo -- mpirun $cmd
    mpirun -bind-to core -map-by numa --report-bindings $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $logname
done

# NCCL - module unsets FI_PROVIDER!
ml reset
ml load NRIS/GPU 
ml load OpenMPI/5.0.9-GCC-14.3.0
ml load NCCL/2.29.2-GCCcore-14.3.0-CUDA-12.9.1
ml list

CMDS=("osu_xccl_bibw -W 64 D D" "osu_xccl_bibw -W 1 D D" "osu_xccl_latency D D")

for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_multinode_srun.txt"
    echo -- srun $cmd
    srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/xccl/pt2pt/$cmd | tee $logname
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_multinode_mpirun.txt"
    echo -- mpirun $cmd
    mpirun -bind-to core -map-by numa --report-bindings $GPUBIND $OSU_HOME/xccl/pt2pt/$cmd | tee $logname
done

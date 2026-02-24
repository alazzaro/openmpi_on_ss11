#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=2 --nodes=1 --ntasks-per-node=2 --cpus-per-task=72
#SBATCH --time=24:00:00

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export SCRIPT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )" &> /dev/null && pwd -P )
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR
source $ROOT_DIR/sourceme_ompi.sh

# with LinkX
export FI_SHM_USE_XPMEM=1
export FI_CXI_RX_MATCH_MODE=software
export FI_PROVIDER=lnx
export FI_LNX_PROV_LINKS=shm+cxi
export OMPI_MCA_opal_common_ofi_provider_include=lnx
export OMPI_MCA_mtl_ofi_av=table
export OMPI_MCA_pml=cm
export OMPI_MCA_mtl=ofi
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2

CMDS=("osu_bibw -W 64 D D" "osu_bibw -W 1 D D" "osu_latency D D" "osu_bibw -W 64 H H" "osu_bibw -W 1 H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    if [ ${USE_SRUN} = 1 ]; then
	logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode_lnx_srun.txt"
	echo -- srun $cmd
	srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
    fi
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode_lnx_mpirun.txt"
    echo -- mpirun $cmd
    mpirun -bind-to core -map-by numa --report-bindings $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
done

# with OpenMPI internal transport
unset FI_SHM_USE_XPMEM
unset FI_PROVIDER
unset FI_CXI_RX_MATCH_MODE
unset FI_LNX_PROV_LINKS
unset OMPI_MCA_opal_common_ofi_provider_include
unset OMPI_MCA_mtl_ofi_av
export OMPI_MCA_pml=ob1
export OMPI_MCA_btl=vader,smcuda,self
unset OMPI_MCA_mtl
export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2

CMDS=("osu_bibw -W 64 D D" "osu_bibw -W 1 D D" "osu_latency D D" "osu_bibw -W 64 H H" "osu_bibw -W 1 H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    if [ ${USE_SRUN} = 1 ]; then
	logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode_ob1_srun.txt"
	echo -- srun $cmd
	srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
    fi
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode_ob1_mpirun.txt"
    echo -- mpirun $cmd
    mpirun -bind-to core -map-by numa --report-bindings $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
done

# NCCL
source $ROOT_DIR/sourceme_nccl.sh

CMDS=("osu_xccl_bibw -W 64 D D" "osu_xccl_bibw -W 1 D D" "osu_xccl_latency D D")
for cmd in "${CMDS[@]}"; do
    if [ ${USE_SRUN} = 1 ]; then
	logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode_ob1_srun.txt"
	echo -- srun $cmd
	srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/xccl/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
    fi
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode_ob1_mpirun.txt"
    echo -- mpirun $cmd
    mpirun -bind-to core -map-by numa --report-bindings $GPUBIND $OSU_HOME/xccl/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
done

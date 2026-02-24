#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=2 --nodes=1 --ntasks-per-node=2 --cpus-per-task=72
#SBATCH --time=0:10:00

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export SCRIPT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )" &> /dev/null && pwd -P )
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR
source $ROOT_DIR/sourceme_craympi.sh

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=XPMEM
# export FI_LOG_LEVEL=debug

CMDS=("osu_bibw -W 64 D D" "osu_bibw -W 1 D D" "osu_latency D D" "osu_bibw -W 64 H H" "osu_bibw -W 1 H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode.txt"
    echo -- srun $cmd
    srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/mpi/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
done

# NCCL
source $ROOT_DIR/sourceme_nccl.sh

CMDS=("osu_xccl_bibw -W 64 D D" "osu_xccl_bibw -W 1 D D" "osu_xccl_latency D D")
for cmd in "${CMDS[@]}"; do
    logname=`echo $cmd | sed -e 's/ /_/g' | sed -e 's/-//g'`"_singlenode.txt"
    echo -- srun $cmd
    srun --cpu-bind=verbose,cores $GPUBIND $OSU_HOME/xccl/pt2pt/$cmd | tee $SCRIPT_DIR/$logname
done

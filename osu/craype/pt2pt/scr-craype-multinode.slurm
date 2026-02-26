#!/bin/bash

#SBATCH --job-name=YourJobname
#SBATCH --gpus-per-node=1 --nodes=2 --ntasks-per-node=1 --cpus-per-task=72
#SBATCH --time=0:10:00

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export OUTPUT_DIR=$SLURM_SUBMIT_DIR
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR

if [ "$OSU_ARGS" == "" ];then
    OSU_ARGS=" -c "
fi

source $ROOT_DIR/sourceme_craympi.sh

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=XPMEM
# export FI_LOG_LEVEL=debug

CMDS=("osu_bibw -b multiple D D" "osu_latency D D" "osu_bibw -b multiple H H" "osu_latency H H")
for cmd in "${CMDS[@]}"; do
    run_osu_cmd "$cmd" "mpi/pt2pt" "_multinode"
done

# NCCL
source $ROOT_DIR/sourceme_nccl.sh

CMDS=("osu_xccl_bibw -b multiple D D" "osu_xccl_latency D D")
for cmd in "${CMDS[@]}"; do
    run_osu_cmd "$cmd" "xccl/pt2pt" "_multinode"
done

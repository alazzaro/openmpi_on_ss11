#!/bin/bash

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export OUTPUT_DIR=$SLURM_SUBMIT_DIR
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR

if [ "$OSU_ARGS" == "" ];then
#    OSU_ARGS=" -c "
    OSU_ARGS=" "
fi

# Enable Cray-mpich and RCCL
USE_CPE=1 source $ROOT_DIR/sourceme_rccl.sh

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=XPMEM
#export FI_MR_CACHE_MONITOR=kdreg2 # no performance contribution
#export GTL_DISABLE_HSA_CACHE=1 # not available in 9.0.1
#export MPICH_GPU_IPC_ENABLED=0
#export MPICH_GPU_IPC_THRESHOLD=524288 # beneficial for `-b multiple` - test1
export MPICH_GPU_IPC_THRESHOLD=131072 # beneficial for `-b multiple` - test 2
#export MPICH_GPU_IPC_THRESHOLD=32768 # beneficial for `-b single`
export MPICH_GPU_IPC_CACHE_MAX_SIZE=1000 # improves performance and makes working with large buffers
# export FI_LOG_LEVEL=debug

export MPICH_VERSION_DISPLAY=1
export GTL_VERSION_DISPLAY=1

echo "============"
cat $0
echo "============"

env

#for FI_CXI_RX_MATCH_MODE in hardware software hybrid; do
for FI_CXI_RX_MATCH_MODE in hybrid; do
    export FI_CXI_RX_MATCH_MODE=$FI_CXI_RX_MATCH_MODE

    SUFFIX="_singlenode_${FI_CXI_RX_MATCH_MODE}_${SLURM_JOB_ID}"

    echo "========"
    echo $SUFFIX
    echo "========"

#    CMDS=("osu_bibw -b multiple -d rocm D D" "osu_latency -d rocm D D" "osu_bibw -b multiple H H" "osu_latency H H")
#    CMDS=("osu_bibw -b single -d rocm D D" "osu_bibw -b single H H")
    CMDS=("osu_bibw -b multiple -d rocm D D" "osu_bibw -b multiple H H")
    #CMDS=("osu_bibw -W 32 -b multiple D D")
    #CMDS=("osu_bibw -b multiple D D")
    #CMDS=("osu_bibw D D")
    #CMDS=("osu_bibw D D" "osu_latency D D" "osu_bibw H H" "osu_latency H H")

    for cmd in "${CMDS[@]}"; do
	run_osu_cmd "$cmd" "mpi/pt2pt" "${SUFFIX}"
    done

    # NCCL/RCCL

#    CMDS=("osu_xccl_bibw -b multiple -d rocm D D" "osu_xccl_latency -d rocm D D")
    CMDS=("osu_xccl_bibw -b multiple -d rocm D D")
#    CMDS=("osu_xccl_bibw -b single -d rocm D D")
    for cmd in "${CMDS[@]}"; do
	run_osu_cmd "$cmd" "xccl/pt2pt" "${SUFFIX}"
    done

done

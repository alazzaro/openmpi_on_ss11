#!/bin/bash

#for NNODES in 1 2 4 8 16 32 64; do
for NNODES in 16; do
#for NNODES in 64; do
sbatch -N $NNODES <<EOF
#!/bin/bash
#SBATCH --ntasks-per-node=8
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o lumi-slurm-%j-coll_N${NNODES}_opt1.out
#SBATCH --time=0:30:00

export SLURM_CPUS_PER_TASK=7

# load runtime environment
ORIGINAL_SCRIPT=\$(scontrol show job "\$SLURM_JOB_ID" | awk -F= '/Command=/{print \$2}')
export OUTPUT_DIR=\$SLURM_SUBMIT_DIR
export ROOT_DIR=\$( cd -- "\$( dirname -- "\${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "\$ROOT_DIR

# Enable Cray-mpich and RCCL
USE_CPE=1 source \$ROOT_DIR/sourceme_rccl.sh

export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=XPMEM
export MPICH_OFI_NIC_POLICY=GPU
#export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

export MPICH_VERSION_DISPLAY=1
export GTL_VERSION_DISPLAY=1

export FI_CXI_RDZV_EAGER_SIZE=1024
export FI_CXI_RDZV_THRESHOLD=65536 # has to be 64k for nccl allgather to perform well

echo "============"
cat $0
echo "============"

env

#for FI_CXI_RX_MATCH_MODE in hardware software hybrid; do
for FI_CXI_RX_MATCH_MODE in hybrid; do
#for FI_CXI_RX_MATCH_MODE in hardware; do
    export FI_CXI_RX_MATCH_MODE=\$FI_CXI_RX_MATCH_MODE

    SUFFIX="_n\${SLURM_NTASKS}_\${FI_CXI_RX_MATCH_MODE}_\${SLURM_JOB_ID}_opt1"

    echo "========"
    echo \$SUFFIX
    echo "========"

    # Consider validation
#    OSU_ARGS=" -c "
    OSU_ARGS=" "

#    if false; then
    (
	CMDS=("osu_alltoall -i 100 -d rocm D D" "osu_allreduce -i 100 -d rocm D D" "osu_allgather -i 100 -d rocm D D" "osu_allreduce -i 100 H H" "osu_alltoall -i 100 H H" "osu_allgather -i 100 H H")
#  	CMDS=("osu_allgather -d rocm D D" "osu_allgather H H")
#	CMDS=("osu_allreduce -m 2^27:2^29:2 -d rocm D D" "osu_allgather -m 2^27:2^29:2 -d rocm D D")
        for cmd in "\${CMDS[@]}"; do
    	    run_osu_cmd "\$cmd" "mpi/collective" "\${SUFFIX}"
        done
    )
#    fi

    # No validation available for RCCL
    OSU_ARGS=" "
#    if false; then
    (
	CMDS=("osu_xccl_alltoall -i 100 -d rocm D D" "osu_xccl_allreduce -i 100 -d rocm D D" "osu_xccl_allgather -i 100 -d rocm D D")
#	CMDS=("osu_xccl_allreduce -m 2^27:2^29:2 -d rocm D D" "osu_xccl_allgather -m 2^27:2^29:2 -d rocm D D")
    	for cmd in "\${CMDS[@]}"; do
            run_osu_cmd "\$cmd" "xccl/collective" "\${SUFFIX}"
     	done
    )
#    fi

    if false; then
    echo "RCCL-tests"
    (
	unset MPICH_GPU_SUPPORT_ENABLED
	unset MPICH_SMP_SINGLE_COPY_MODE
	FLAGS="-d uint8 -b 1 -e 128M -f 2 -g 1"
	CMDS=("alltoall_perf \${FLAGS}" "all_reduce_perf \${FLAGS}" "all_gather_perf \${FLAGS}")
    	for cmd in "\${CMDS[@]}"; do
	    logname=\$(echo "\${cmd}" | sed -e 's/ /_/g' -e 's/-//g')
	    echo -- srun \$cmd
	    srun --cpu-bind=verbose,cores \${GPUBIND} \${PREFIX_RCCL}/bin/\$cmd \${FLAGS} | tee \${OUTPUT_DIR}/\${logname}"\${SUFFIX}.txt"
	done
    )
    fi
done

EOF


done

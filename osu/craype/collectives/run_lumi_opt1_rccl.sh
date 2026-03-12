#!/bin/bash

#for NNODES in 1 2 4 8 16 32 64; do
for NNODES in 1 2 16; do
#for NNODES in 2; do
#for NNODES in 64; do
sbatch -N $NNODES <<EOF
#!/bin/bash
#SBATCH --ntasks-per-node=8
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o lumi-slurm-%j-coll_N${NNODES}_opt1_rccl.out
#SBATCH --time=0:30:00

export SLURM_CPUS_PER_TASK=7

# load runtime environment
ORIGINAL_SCRIPT=\$(scontrol show job "\$SLURM_JOB_ID" | awk -F= '/Command=/{print \$2}')
export OUTPUT_DIR=\$SLURM_SUBMIT_DIR
export ROOT_DIR=\$( cd -- "\$( dirname -- "\${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "\$ROOT_DIR

# Enable Cray-mpich and RCCL
USE_CPE=1 source \$ROOT_DIR/sourceme_rccl.sh

#export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

export MPICH_VERSION_DISPLAY=1
export GTL_VERSION_DISPLAY=1

export HSA_FORCE_FINE_GRAIN_PCIE=1
export FI_CXI_RDZV_THRESHOLD=0
#export FI_MR_CACHE_MONITOR=kdreg2 # not useful, can avoid deadline on RCCL
export FI_MR_CACHE_MONITOR=userfaultfd # not useful, can avoid deadline on RCCL
export FI_CXI_RDZV_EAGER_SIZE=0
export FI_CXI_RDZV_PROTO="alt_read"
export FI_CXI_DEFAULT_CQ_SIZE="131072" # default value
export FI_CXI_DEFAULT_TX_SIZE=1024
export FI_CXI_DISABLE_HOST_REGISTER=1
export FI_CXI_DISABLE_NON_INJECT_MSG_IDC="1"
export FI_CXI_RDZV_GET_MIN="0"

export NCCL_CROSS_NIC=1
export NCCL_NET_GDR_LEVEL=PHB
export NCCL_SOCKET_IFNAME=hsn
export NCCL_NET="AWS Libfabric"
export NCCL_MIN_NCHANNELS="4"

echo "============"
cat $0
echo "============"

env

#for FI_CXI_RX_MATCH_MODE in hardware software hybrid; do
for FI_CXI_RX_MATCH_MODE in hybrid; do
    export FI_CXI_RX_MATCH_MODE=\$FI_CXI_RX_MATCH_MODE

    SUFFIX="_n\${SLURM_NTASKS}_\${FI_CXI_RX_MATCH_MODE}_\${SLURM_JOB_ID}_opt1_rccl"

    echo "========"
    echo \$SUFFIX
    echo "========"

    echo "RCCL-tests"
    (
	unset MPICH_GPU_SUPPORT_ENABLED
	unset MPICH_SMP_SINGLE_COPY_MODE
#	FLAGS="-d uint8 -b 1 -e 128M -f 2 -g 1"
	FLAGS="-d int8 -b 1 -e 128M -f 2 -g 1"
#	FLAGS="-d double -b 1 -e 128M -f 2 -g 1"
	# Values taken from https://www.olcf.ornl.gov/wp-content/uploads/OLCF_AI_Training_0417_2024.pdf
	# Page 15 and 16
#	FLAGS="-b 64K -e 4G -f 2 -g 1"
#	for i in 1 2 3 4 5; do
#	sleep 5
#	mkdir -p \${OUTPUT_DIR}/rccl_\$i
	CMDS=("alltoall_perf \${FLAGS}" "all_reduce_perf \${FLAGS}" "all_gather_perf \${FLAGS}")
#	CMDS=("all_reduce_perf \${FLAGS}")
    	for cmd in "\${CMDS[@]}"; do
	    logname=\$(echo "\${cmd}" | sed -e 's/ /_/g' -e 's/-//g')
	    echo -- srun \$cmd
	    srun --cpu-bind=verbose,cores \${GPUBIND} \${PREFIX_RCCL}/bin/\$cmd \${FLAGS} | tee \${OUTPUT_DIR}/\${logname}"\${SUFFIX}.txt"
#	    srun --cpu-bind=verbose,cores \${GPUBIND} \${PREFIX_RCCL}/bin/\$cmd \${FLAGS} | tee \${OUTPUT_DIR}/rccl_\$i/\${logname}"\${SUFFIX}.txt"
	done
#	done
    )
done

EOF

done

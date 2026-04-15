#!/bin/bash

#for NNODES in 1 2 4 8 16 32 64; do
#for NNODES in 1 2 16; do
for NNODES in 2; do
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
#SBATCH --time=0:10:00
#SBATCH --network=disable_rdzv_get

# load runtime environment
ORIGINAL_SCRIPT=\$(scontrol show job "\$SLURM_JOB_ID" | awk -F= '/Command=/{print \$2}')
export OUTPUT_DIR=\$SLURM_SUBMIT_DIR
export ROOT_DIR=\$( cd -- "\$( dirname -- "\${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "\$ROOT_DIR

# Enable OpenMPI and RCCL
USE_CPE=0 source \$ROOT_DIR/sourceme_rccl.sh

# LUMI Binding
#export BINDING="--bind-to core --map-by L3cache:pe=7 --mca hwloc_base_binding_policy core --mca hwloc_base_mem_bind policy:bind"
export BINDING="--bind-to numa --map-by numa"

export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2
export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

echo "============"
cat $0
echo "============"

# opts
# https://github.com/HewlettPackard/shs-ccl-docs/blob/main/rccl/rccl_tuning_guide.md
#export HSA_FORCE_FINE_GRAIN_PCIE=1
#export FI_CXI_RDZV_THRESHOLD=0
#export FI_MR_CACHE_MONITOR=kdreg2 # not useful, can avoid deadlock in RCCL
#export FI_MR_CACHE_MONITOR=userfaultfd
#export FI_CXI_RDZV_EAGER_SIZE=0
#export FI_CXI_RDZV_PROTO="alt_read"
#export FI_CXI_DEFAULT_CQ_SIZE="131072" # default value
#export FI_CXI_DEFAULT_TX_SIZE=1024
#export FI_CXI_DISABLE_HOST_REGISTER=1
#export FI_CXI_DISABLE_NON_INJECT_MSG_IDC="1"
#export FI_CXI_RDZV_GET_MIN="0"

export NCCL_CROSS_NIC=1
export NCCL_NET_GDR_LEVEL=PHB
export NCCL_SOCKET_IFNAME=hsn2,hsn1,hsn3,hsn0
export NCCL_NET="AWS Libfabric"
export NCCL_MIN_NCHANNELS="4"

#export NCCL_ENABLE_DMABUF_SUPPORT=1
#export NCCL_DMABUF_ENABLE=1
export FI_CXI_DEVICE_NAME="cxi2,cxi1,cxi3,cxi0"

env

#for FI_CXI_RX_MATCH_MODE in software hybrid; do
for FI_CXI_RX_MATCH_MODE in hybrid; do
    export FI_CXI_RX_MATCH_MODE=\$FI_CXI_RX_MATCH_MODE

    SUFFIX="_n\${SLURM_NTASKS}_\${FI_CXI_RX_MATCH_MODE}_\${SLURM_JOB_ID}_opt1_rccl"

    echo "========"
    echo \$SUFFIX
    echo "========"

    (
        echo "RCCL-tests"

#	FLAGS="-d uint8 -b 1 -e 128M -f 2 -g 1"
	# Values taken from https://www.olcf.ornl.gov/wp-content/uploads/OLCF_AI_Training_0417_2024.pdf
        # Page 15 and 16
        FLAGS="-b 64K -e 4G -f 2 -g 1"
	CMDS=("alltoall_perf \${FLAGS}" "all_reduce_perf \${FLAGS}" "all_gather_perf \${FLAGS}")
    	for cmd in "\${CMDS[@]}"; do
	    logname=\$(echo "\${cmd}" | sed -e 's/ /_/g' -e 's/-//g')
	    echo -- mpirun \$cmd
	    mpirun \${BINDING} --report-bindings \${GPUBIND} \${PREFIX_RCCL}/bin/\$cmd \${FLAGS} | tee \${OUTPUT_DIR}/\${logname}"\${SUFFIX}.txt"
	done
    )
done

EOF


done

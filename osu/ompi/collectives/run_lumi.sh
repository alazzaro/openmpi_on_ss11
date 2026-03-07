#!/bin/bash

for NNODES in 1 2 4 8 16 32 64; do
#for NNODES in 4; do
#for NNODES in 64; do
sbatch -N $NNODES <<EOF
#!/bin/bash
#SBATCH --ntasks-per-node=8
#SBATCH -A project_462000031
#SBATCH -p standard-g
#SBATCH --gres=gpu:8
#SBATCH --exclusive
#SBATCH --network=single_node_vni
#SBATCH -o lumi-slurm-%j-coll_N${NNODES}.out
#SBATCH --time=0:30:00

# load runtime environment
ORIGINAL_SCRIPT=\$(scontrol show job "\$SLURM_JOB_ID" | awk -F= '/Command=/{print \$2}')
export OUTPUT_DIR=\$SLURM_SUBMIT_DIR
export ROOT_DIR=\$( cd -- "\$( dirname -- "\${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "\$ROOT_DIR

# Enable OpenMPI and RCCL
USE_CPE=0 source \$ROOT_DIR/sourceme_rccl.sh

# LUMI Binding
export BINDING="--bind-to core --map-by L3cache:pe=7 --mca hwloc_base_binding_policy core --mca hwloc_base_mem_bind policy:bind"

export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2
#export NCCL_DEBUG=INFO
#export FI_LOG_LEVEL=debug

echo "============"
cat $0
echo "============"

env

for FI_CXI_RX_MATCH_MODE in software hybrid; do
    export FI_CXI_RX_MATCH_MODE=\$FI_CXI_RX_MATCH_MODE

    SUFFIX="_n\${SLURM_NTASKS}_\${FI_CXI_RX_MATCH_MODE}_\${SLURM_JOB_ID}"

    echo "========"
    echo \$SUFFIX
    echo "========"

    # Consider validation
#    OSU_ARGS=" -c "
    OSU_ARGS=" "

#    if false; then
    if [ "\${FI_CXI_RX_MATCH_MODE}" == "software" ]; then
    (
        echo "with LinkX"

        export FI_SHM_USE_XPMEM=0 # otherwise the D2D breaks with LNX
        export FI_PROVIDER=lnx
        export FI_LNX_PROV_LINKS=shm+cxi # changed in the binding script
        export OMPI_MCA_opal_common_ofi_provider_include=lnx
        export OMPI_MCA_mtl_ofi_av=table
        export OMPI_MCA_pml=cm
        export OMPI_MCA_mtl=ofi
	export OMPI_MCA_smsc=xpmem

	# opts
#	export FI_CXI_RDZV_THRESHOLD=4096

	CMDS=("osu_alltoall -d rocm D D" "osu_allreduce -d rocm D D" "osu_allgather -d rocm D D")
#  	CMDS=("osu_allgather -d rocm D D" "osu_allgather H H")
        for cmd in "\${CMDS[@]}"; do
    	    run_osu_cmd "\$cmd" "mpi/collective" "_lnx\${SUFFIX}"
        done

        export FI_SHM_USE_XPMEM=1

	CMDS=("osu_allreduce H H" "osu_alltoall H H" "osu_allgather H H")
        for cmd in "\${CMDS[@]}"; do
    	    run_osu_cmd "\$cmd" "mpi/collective" "_lnx\${SUFFIX}"
        done

    )
    fi # only software
#    fi

    (
        echo "no OpenMPI internal transport, only libfabric. Use CXI directly"

        export FI_SHM_USE_XPMEM=1
	export FI_PROVIDER=cxi
    	unset FI_LNX_PROV_LINKS
    	export OMPI_MCA_opal_common_ofi_provider_include=cxi
    	export OMPI_MCA_mtl_ofi_av=table
    	export OMPI_MCA_pml=cm
    	export OMPI_MCA_mtl=ofi
	export OMPI_MCA_smsc=xpmem

        CMDS=("osu_alltoall -d rocm D D" "osu_allreduce -d rocm D D" "osu_allgather -d rocm D D" "osu_allreduce H H" "osu_alltoall H H" "osu_allgather H H")
#       CMDS=("osu_allgather -d rocm D D" "osu_allgather H H")
        for cmd in "\${CMDS[@]}"; do
            run_osu_cmd "\$cmd" "mpi/collective" "_cxi\${SUFFIX}"
        done
    )

    if [ "\${FI_CXI_RX_MATCH_MODE}" == "hybrid" ]; then
    (

        # No validation available for RCCL
    	OSU_ARGS=" "

	CMDS=("osu_xccl_alltoall -d rocm D D" "osu_xccl_allreduce -d rocm D D" "osu_xccl_allgather -d rocm D D")
    	for cmd in "\${CMDS[@]}"; do
            run_osu_cmd "\$cmd" "xccl/collective" "\${SUFFIX}"
     	done
    )

#    if false; then
    (
        echo "RCCL-tests"

	FLAGS="-d uint8 -b 1 -e 128M -f 2 -g 1"
	CMDS=("alltoall_perf \${FLAGS}" "all_reduce_perf \${FLAGS}" "all_gather_perf \${FLAGS}")
    	for cmd in "\${CMDS[@]}"; do
	    logname=\$(echo "\${cmd}" | sed -e 's/ /_/g' -e 's/-//g')
	    echo -- mpirun \$cmd
	    mpirun \${BINDING} --report-bindings \${GPUBIND} \${PREFIX_RCCL}/bin/\$cmd \${FLAGS} | tee \${OUTPUT_DIR}/\${logname}"\${SUFFIX}.txt"
	done
    )
#    fi

    fi # only hybrid

done

if [ "${NNODES}" == "1" ]; then
(
    echo "with OpenMPI internal transport"

    SUFFIX="_n\${SLURM_NTASKS}_\${SLURM_JOB_ID}"

    unset FI_SHM_USE_XPMEM
    unset FI_PROVIDER
    unset FI_CXI_RX_MATCH_MODE
    unset FI_LNX_PROV_LINKS
    unset OMPI_MCA_opal_common_ofi_provider_include
    unset OMPI_MCA_mtl_ofi_av
    export OMPI_MCA_pml=ob1
    # CUDA
    #  export OMPI_MCA_btl=vader,smcuda,self
    # ROCM
    export OMPI_MCA_btl=vader,sm,self
    unset OMPI_MCA_mtl
    export OMPI_MCA_smsc=xpmem # Only OpenMPI

    CMDS=("osu_alltoall -d rocm D D" "osu_allreduce -d rocm D D" "osu_allgather -d rocm D D" "osu_allreduce H H" "osu_alltoall H H" "osu_allgather H H")
    for cmd in "\${CMDS[@]}"; do
        run_osu_cmd "\$cmd" "mpi/collective" "_ob1\${SUFFIX}"
    done
)
fi # single node

EOF


done

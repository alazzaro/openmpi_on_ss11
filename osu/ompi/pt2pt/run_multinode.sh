#!/bin/bash

# load runtime environment
ORIGINAL_SCRIPT=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/Command=/{print $2}')
export OUTPUT_DIR=$SLURM_SUBMIT_DIR
export ROOT_DIR=$( cd -- "$( dirname -- "${ORIGINAL_SCRIPT}" )/../../.." &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR

if [ "$OSU_ARGS" == "" ];then
    OSU_ARGS=" -c "
fi

# Enable OpenMPI and RCCL
USE_CPE=0 source $ROOT_DIR/sourceme_rccl.sh

echo "============"
cat $0
echo "============"

env

export PRTE_MCA_ras_base_launch_orted_on_hn=1
export PMIX_MCA_gds=^shmem2

#if false; then
for FI_CXI_RX_MATCH_MODE in hardware software hybrid; do
#for FI_CXI_RX_MATCH_MODE in hybrid; do
    export FI_CXI_RX_MATCH_MODE=$FI_CXI_RX_MATCH_MODE

    SUFFIX="multinode_${FI_CXI_RX_MATCH_MODE}_${SLURM_JOB_ID}"

    echo "========"
    echo $SUFFIX
    echo "========"

#    if false; then
    (
        echo "with LinkX"

        export FI_SHM_USE_XPMEM=1
        export FI_PROVIDER=lnx
        export FI_LNX_PROV_LINKS=shm+cxi # changed in the binding script
        export OMPI_MCA_opal_common_ofi_provider_include=lnx
        export OMPI_MCA_mtl_ofi_av=table
        export OMPI_MCA_pml=cm
        export OMPI_MCA_mtl=ofi
        #    export FI_LOG_LEVEL=debug

        CMDS=("osu_bibw -b multiple -d rocm D D" "osu_latency -d rocm D D" "osu_bibw -b multiple H H" "osu_latency H H")
        #CMDS=("osu_bibw -W 32 -b multiple D D")
        #CMDS=("osu_bibw -b multiple D D")
        #CMDS=("osu_bibw D D")
        #CMDS=("osu_bibw D D" "osu_latency D D" "osu_bibw H H" "osu_latency H H")

        for cmd in "${CMDS[@]}"; do
            run_osu_cmd "$cmd" "mpi/pt2pt" "_lnx_${SUFFIX}"
        done
    )
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

	CMDS=("osu_bibw -b multiple -d rocm D D" "osu_latency -d rocm D D" "osu_bibw -b multiple H H" "osu_latency H H")
	for cmd in "${CMDS[@]}"; do
	    run_osu_cmd "$cmd" "mpi/pt2pt" "_cxi_${SUFFIX}"
	done
    )

    # NCCL/RCCL

    CMDS=("osu_xccl_bibw -b multiple -d rocm D D" "osu_xccl_latency -d rocm D D")
    for cmd in "${CMDS[@]}"; do
        run_osu_cmd "$cmd" "xccl/pt2pt" "_${SUFFIX}"
    done
done
#fi

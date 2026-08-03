
function change_dir() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $SCRIPT_DIR
}

OLDDIR=`pwd`
change_dir

if [ -z "$GPU_ACCL" ]; then
	export GPU_ACCL=nccl
fi
source sourceme_libfabric.sh

# This should have happened in the libfabric script, but just in case, we check again here. We want to make sure that the correct environment modules are loaded for the system configuration before we proceed with the NCCL setup.
case "$SYSTEM_CONFIG" in
    "nris_cuda"|"nris_generic")
	if [ "${CRAY_MPICH_VER}" == "" ]; then
	    ml load NRIS/GPU
	    ml load NCCL/2.29.2-GCCcore-14.3.0-CUDA-12.9.1
	    return 0
	fi
	;;
    "cray_cuda")
	# NCCL modules already loaded by sourceme_libfabric.sh
	# Ensure CUDA_HOME is properly set for NCCL compilation
	if [[ -z "$CUDA_HOME" ]]; then
	    echo "Warning: CUDA_HOME not set after loading CUDA modules"
	    echo "Info: On Cray systems, CUDA may only be available on compute nodes"
	    # Try to find CUDA in NVIDIA HPC SDK
	    if [[ -d "/opt/nvidia/hpc_sdk/Linux_x86_64" ]]; then
	        latest_cuda=$(ls -1 /opt/nvidia/hpc_sdk/Linux_x86_64/ | grep -E '^[0-9]+\.[0-9]+$' | sort -V | tail -1)
	        if [[ -n "$latest_cuda" && -d "/opt/nvidia/hpc_sdk/Linux_x86_64/$latest_cuda/cuda" ]]; then
	            export CUDA_HOME="/opt/nvidia/hpc_sdk/Linux_x86_64/$latest_cuda/cuda"
	            echo "Set CUDA_HOME to: $CUDA_HOME"
	        else
	            echo "Info: Consider one of these options:"
	            echo "  1. Build NCCL on a compute node with GPU access"
	            echo "  2. Use a pre-compiled NCCL from modules (if available)"
	            echo "  3. Set CUDA_HOME manually if you know the CUDA path"
	        fi
	    else
	        echo "Info: NVIDIA HPC SDK not found"
	        echo "Consider these options for NCCL:"
	        echo "  1. Load NCCL module if available: module load NCCL"
	        echo "  2. Build on compute node with GPU access"
	        echo "  3. Use system-provided NCCL installation"
	    fi
	fi
	echo "CUDA_HOME for NCCL: ${CUDA_HOME:-\"(not set - see suggestions above)\"}"
	;;
    "cray_rocm"|"rocm_generic"|"cray_preinstalled")
	# NCCL not applicable for ROCm systems (use RCCL instead)
	echo "NCCL not available for ROCm systems, use RCCL instead"
	return -1
	;;
    "cuda_generic")
	# Generic CUDA systems - try to find NCCL
	if [[ -d "/usr/local/nccl" ]]; then
	    export NCCL_ROOT=/usr/local/nccl
	elif [[ -n "$NCCL_PATH" ]]; then
	    export NCCL_ROOT=$NCCL_PATH
	fi
	;;
    "cray_generic"|"generic")
        echo "No NCCL configuration available for this system"
        return -1
        ;;
esac

export PREFIX_NCCL=$ROOT_DIR/install_nccl # installation directory
export NCCL_DIR=$ROOT_DIR/nccl

export PATH=${PREFIX_NCCL}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_NCCL}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_NCCL/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_NCCL/man:$MANPATH

cd $OLDDIR

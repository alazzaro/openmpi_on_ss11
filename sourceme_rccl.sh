
# We build RCCL twice:
# 1. with the system libfabric (requires to set USE_CPE==1)
# 2. with the custom installed libfabric (USE_CPE!=1)

function change_dir() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    pushd "$SCRIPT_DIR"
}

change_dir

if [ "${USE_CPE}" == "1" ]; then
    # Take default libfabric on the system
    source sourceme_craympi.sh
    export PREFIX_LIBFABRIC=$(pkg-config --variable=prefix libfabric)
    export ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
    echo "ROOT_DIR = "$ROOT_DIR
    export PREFIX_RCCL=$ROOT_DIR/install_rccl_cpe # installation directory
else
    source sourceme_ompi.sh
    export PREFIX_RCCL=$ROOT_DIR/install_rccl # installation directory
fi

case "$SYSTEM_CONFIG" in
    "cray_rocm"|"rocm_generic")
	echo ${PREFIX_LIBFABRIC}
	echo ${PREFIX_RCCL}
	;;
    "nris_cuda"|"nris_generic"|"cray_cuda"|"cuda_generic")
	echo "RCCL not applicable for CUDA systems, use NCCL instead"
	return -1
	;;
    "cray_preinstalled")
	echo ${PREFIX_LIBFABRIC}
	echo ${PREFIX_RCCL}
	;;
    "cray_generic"|"generic")
        echo "No RCCL configuration available for this system"
        return -1
        ;;
esac

export RCCL_DIR=$ROOT_DIR/rccl
export PATH=${PREFIX_RCCL}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_RCCL}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_RCCL/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_RCCL/man:$MANPATH

popd

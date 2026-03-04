
function change_dir() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $SCRIPT_DIR
}

OLDDIR=`pwd`
change_dir

source sourceme_libfabric.sh

case "$USER" in
    marcink)
	if [ "${CRAY_MPICH_VER}" == "" ]; then
	    ml load NRIS/GPU
	    ml load NCCL/2.29.2-GCCcore-14.3.0-CUDA-12.9.1
	    return 0
	fi
	;;
    *)
        echo "User not recongnized"
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

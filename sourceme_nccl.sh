
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
	fi
	return 0
	;;
    *)
        echo "User not recongnized"
        exit -1
        ;;
esac

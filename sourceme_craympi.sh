
export PE_LD_LIBRARY_PATH=system # Force update of the LD_LIBRARY_PATH, instead of CRAY_LD_LIBRARY_PATH

module load PrgEnv-gnu
module load libfabric

case "$USER" in
    lazzaroa)
	module load cray-mpich/9.0.1
	module swap craype-x86-rome craype-x86-trento
	module load craype-accel-amd-gfx90a
	module load rocm
        ;;
    *)
        echo "User not recongnized"
        exit -1
        ;;
esac

module list

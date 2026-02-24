module load PrgEnv-gnu
module load libfabric
case "$USER" in
    lazzaroa)
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


function change_dir() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $SCRIPT_DIR
}

# system-specific - check if your system supports running OpenMPI apps using srun
export USE_SRUN=0

case "$USER" in
    lazzaroa)
        XPMEM_OMPI="--with-cray-xpmem=yes --with-xpmem=${XPMEM_ROOT}"
        GPU_OMPI="--with-rocm=$ROCM_PATH"
        ;;
    marcink)
	# seems to be needed. slurm race?
	sleep 2
	ml reset
	ml load NRIS/GPU 
	ml load OpenMPI/5.0.9-GCC-14.3.0
	export OSU_HOME=/cluster/projects/nn9999k/marcink/software/osu-eb/libexec/osu-micro-benchmarks/
	export GPUBIND=/cluster/home/marcink/hpe_cug_paper/gpubind.sh
	export USE_SRUN=1
	return 0
	;;
    *)
        echo "User not recongnized"
        exit -1
        ;;
esac

OLDDIR=`pwd`
change_dir

source sourceme_libfabric.sh

export PREFIX_OMPI=$ROOT_DIR/install_ompi # installation directory
export OMPI_DIR=$ROOT_DIR/openmpi5

export PATH=${PREFIX_OMPI}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_OMPI}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_OMPI/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_OMPI/man:$MANPATH

cd $OLDDIR

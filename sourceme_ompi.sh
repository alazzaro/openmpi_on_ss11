run_osu_cmd() {
    local cmd="$1"
    local osusubdir="$2"
    local logsuffix="$3"

    # Build logname from original cmd (spaces -> _, remove -)
    local logname
    logname=$(echo "$cmd" | sed -e 's/ /_/g' -e 's/-//g')

    # Replace first space in cmd with $OSU_ARGS
    cmd=$(echo "$cmd" | sed -e "s/ /$OSU_ARGS/")

    # Split cmd into program + args
    # shellcheck disable=SC2086
    set -- $cmd
    local prog="$1"
    shift
    local args=("$@")

    # Full path to the OSU executable
    local fullprog="$OSU_HOME/$osusubdir/$prog"

    if [ "${USE_SRUN}" = "1" ]; then
	echo -- srun "$fullprog" "${args[@]}"
        srun --cpu-bind=verbose,cores $GPUBIND "$fullprog" "${args[@]}" | tee "$OUTPUT_DIR/$logname${logsuffix}_srun.txt"
    fi

    echo -- mpirun "$fullprog" "${args[@]}"
    # -bind-to core destroys performance with nccl. Loooks like another thread running.
    # gpu-1-62:4117765:4118287 [0] NCCL INFO [Proxy Service] Device 0 CPU core 73
    # gpu-1-62:4117765:4118290 [0] NCCL INFO [Proxy Service UDS] Device 0 CPU core 74
    mpirun -bind-to numa -map-by numa --report-bindings $GPUBIND "$fullprog" "${args[@]}" | tee "$OUTPUT_DIR/$logname${logsuffix}_mpirun.txt"
}

function change_dir() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
    cd $SCRIPT_DIR
}

# system-specific - check if your system supports running OpenMPI apps using srun
export USE_SRUN=0

case "$USER" in
    lazzaroa)
        XPMEM_OMPI="--with-cray-xpmem=yes --with-xpmem=${XPMEM_ROOT}"
        GPU_OMPI="--with-rocm=$ROCM_PATH"
	OSU_COMPILE_FLAGS="--enable-rocm"
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
        return -1
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

export OSU_INSTALL=$ROOT_DIR/osu/osu-ompi/
export OSU_HOME=$OSU_INSTALL/libexec/osu-micro-benchmarks/
export GPUBIND=$ROOT_DIR/select_gpu.sh

cd $OLDDIR

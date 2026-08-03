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
    BINDING=${BINDING:-"--bind-to numa --map-by numa"}
    mpirun ${BINDING} --report-bindings $GPUBIND "$fullprog" "${args[@]}" | tee "$OUTPUT_DIR/$logname${logsuffix}_mpirun.txt"
}

function change_dir() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $SCRIPT_DIR
}

# system-specific - check if your system supports running OpenMPI apps using srun
export USE_SRUN=0

OLDDIR=`pwd`
change_dir

source sourceme_libfabric.sh

case "$SYSTEM_CONFIG" in
    "cray_rocm")
        if [[ -n "$XPMEM_ROOT" ]]; then
            XPMEM_OMPI="--with-cray-xpmem=yes --with-xpmem=${XPMEM_ROOT}"
            echo "Using XPMEM: $XPMEM_ROOT"
        else
            echo "Warning: XPMEM_ROOT not set, proceeding without XPMEM support"
            XPMEM_OMPI=""
        fi
        GPU_OMPI="--with-rocm=$ROCM_PATH"
	OSU_COMPILE_FLAGS="--enable-rocm"

	export PREFIX_OMPI=$ROOT_DIR/install_ompi # installation directory
	export OMPI_DIR=$ROOT_DIR/openmpi5

	export PATH=${PREFIX_OMPI}/bin:${PATH}
	export LD_LIBRARY_PATH=${PREFIX_OMPI}/lib:${LD_LIBRARY_PATH}
	export PKG_CONFIG_PATH=$PREFIX_OMPI/lib/pkgconfig:$PKG_CONFIG_PATH
	export MANPATH=$PREFIX_OMPI/share/man:$MANPATH

	export OSU_INSTALL=$ROOT_DIR/osu/osu-ompi/
	export OSU_HOME=$OSU_INSTALL/libexec/osu-micro-benchmarks/
	export GPUBIND=$ROOT_DIR/select_gpu.sh

	cd $OLDDIR
        ;;
    "cray_cuda")
        if [[ -n "$XPMEM_ROOT" ]]; then
            XPMEM_OMPI="--with-xpmem=${XPMEM_ROOT}"
            echo "Using XPMEM: $XPMEM_ROOT"
        else
            echo "Warning: XPMEM_ROOT not set, proceeding without XPMEM support"
            XPMEM_OMPI=""
        fi
        if [[ -n "$CUDA_HOME" ]]; then
            GPU_OMPI="--with-cuda=$CUDA_HOME"
        elif [[ -n "$CUDA_PATH" ]]; then
            GPU_OMPI="--with-cuda=$CUDA_PATH"
        fi
	OSU_COMPILE_FLAGS="--enable-cuda"
        ;;
    "nris_cuda"|"nris_generic")
	# seems to be needed. slurm race?
	sleep 2
	ml reset
	ml load NRIS/GPU

	ml load OpenMPI/5.0.9-GCC-14.3.0
	# Use configured OSU and GPUBIND paths from sourceme_libfabric.sh
	export OSU_HOME="$USER_OSU_HOME"
	export GPUBIND="$USER_GPUBIND"

	export USE_SRUN=1
	cd $OLDDIR
	return 0
	;;
    "rocm_generic")
        if [[ -n "$ROCM_PATH" ]]; then
            GPU_OMPI="--with-rocm=$ROCM_PATH"
        fi
	OSU_COMPILE_FLAGS="--enable-rocm"
        ;;
    "cuda_generic")
        if [[ -n "$CUDA_HOME" ]]; then
            GPU_OMPI="--with-cuda=$CUDA_HOME"
        elif [[ -n "$CUDA_PATH" ]]; then
            GPU_OMPI="--with-cuda=$CUDA_PATH"
        fi
	OSU_COMPILE_FLAGS="--enable-cuda"
        ;;
    "cray_preinstalled"|"cray_generic"|"generic")
        echo "No OpenMPI configuration available for this system"
        cd $OLDDIR
        return -1
        ;;
esac

export PREFIX_OMPI=$ROOT_DIR/install_ompi # installation directory
export OMPI_DIR=$ROOT_DIR/openmpi5

export PATH=${PREFIX_OMPI}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_OMPI}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_OMPI/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_OMPI/man:$MANPATH

export OSU_INSTALL=$ROOT_DIR/osu/osu-ompi/
export OSU_HOME="${USER_OSU_HOME:-$OSU_INSTALL/libexec/osu-micro-benchmarks/}"
export GPUBIND="${USER_GPUBIND:-$ROOT_DIR/select_gpu.sh}"

cd $OLDDIR


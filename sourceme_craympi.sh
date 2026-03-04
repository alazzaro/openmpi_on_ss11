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

    echo -- srun "$fullprog" "${args[@]}"
    srun --cpu-bind=verbose,cores $GPUBIND "$fullprog" "${args[@]}" | tee "$OUTPUT_DIR/$logname${logsuffix}.txt"
}

export PE_LD_LIBRARY_PATH=system # Force update of the LD_LIBRARY_PATH, instead of CRAY_LD_LIBRARY_PATH

export ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR

# Source libfabric config to get SYSTEM_CONFIG
source sourceme_libfabric.sh

case "$SYSTEM_CONFIG" in
    "cray_rocm")
	# Basic modules (PrgEnv-gnu, rocm, xpmem) already loaded by sourceme_libfabric.sh
	module load libfabric
	module load cray-mpich/9.0.1
	module swap craype-x86-rome craype-x86-trento
	module load craype-accel-amd-gfx90a
	OSU_COMPILE_FLAGS="--enable-rocm"
        ;;
    "cray_cuda")
	# Basic modules (PrgEnv-gnu, cuda, xpmem) already loaded by sourceme_libfabric.sh
	module load libfabric
	module load cray-mpich/9.0.1
	# Try different NVIDIA accelerator module variations
	if module avail craype-accel-nvidia90 &>/dev/null 2>&1; then
	    module load craype-accel-nvidia90
	elif module avail craype-accel-nvidia &>/dev/null 2>&1; then
	    module load craype-accel-nvidia
	fi
	OSU_COMPILE_FLAGS="--enable-cuda"
        ;;
    "nris_cuda"|"nris_generic")
	ml reset
	ml load CrayEnv
	# ml swap cray-mpich/9.0.1
	ml load cuda/12.6
	ml swap PrgEnv-cray PrgEnv-gnu
	ml swap gcc-native/13.2
	ml load craype-accel-nvidia90
	# Use configured OSU and GPUBIND paths from sourceme_libfabric.sh
	export OSU_HOME="$USER_OSU_HOME"
	export GPUBIND="$USER_GPUBIND"
	# Try to get NCCL library path from loaded modules
	if [[ -n "$EBROOTNCCL" ]]; then
	    export LD_LIBRARY_PATH="$EBROOTNCCL/lib:$LD_LIBRARY_PATH"
	elif [[ -n "$NCCL_ROOT" ]]; then
	    export LD_LIBRARY_PATH="$NCCL_ROOT/lib:$LD_LIBRARY_PATH"
	else
	    echo "Warning: NCCL library path not found from modules"
	fi
	;;
    "cray_preinstalled"|"cray_generic"|"rocm_generic"|"cuda_generic"|"generic")
        echo "No Cray MPI configuration available for this system"
        return -1
        ;;
esac

module list

export OSU_INSTALL=$ROOT_DIR/osu/osu-craype/
export OSU_HOME="${USER_OSU_HOME:-$OSU_INSTALL/libexec/osu-micro-benchmarks/}"
export GPUBIND="${USER_GPUBIND:-$ROOT_DIR/select_gpu.sh}"

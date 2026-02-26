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

case "$USER" in
    lazzaroa)
	module load PrgEnv-gnu
	module load libfabric
	module load cray-mpich/9.0.1
	module swap craype-x86-rome craype-x86-trento
	module load craype-accel-amd-gfx90a
	module load rocm
        ;;
    marcink)
	ml reset
	ml load CrayEnv
	ml load cuda/12.6
	ml swap PrgEnv-cray PrgEnv-gnu
	ml swap gcc-native/13.2
	ml load craype-accel-nvidia90
	export OSU_HOME=/cluster/projects/nn9999k/marcink/software/osu-craype/libexec/osu-micro-benchmarks/
	export GPUBIND=/cluster/home/marcink/hpe_cug_paper/gpubind.sh
	export LD_LIBRARY_PATH=/cluster/home/marcink/software/nccl/nccl-2.29-craype/lib/:$LD_LIBRARY_PATH
	;;
    *)
        echo "User not recongnized"
        exit -1
        ;;
esac

module list


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

#!/bin/bash

#MYUSER="marcink"
#MYUSER="alazzaro"
MYUSER=${MYUSER:-${USER}}

echo "User: $MYUSER"

case "$MYUSER" in
    lazzaroa|alazzaro)
	SYSTEM="lumi"
	suffix="amd"
	NGPUS="8 64"
	XCCL="RCCL"
	XCCL_TESTS="rccl-tests"
	;;
    marcink)
	SYSTEM="olivia"
	suffix="cuda"
	NGPUS="4 64"
	XCCL="NCCL"
	XCCL_TESTS="nccl-tests"
	;;
    *)
	echo "User not recongnized"
        exit -1
esac

mkdir -p ${SYSTEM}

for n in ${NGPUS}; do
    cmp='cxi'
    TAGMODE="hybrid"
    if [[ ( ${n} == 4 && "${SYSTEM}" == "olivia" ) || ( ${n} == 8 && "${SYSTEM}" == "lumi" ) ]]; then
	cmp='ob1'
	TAGMODE=""
    fi
    echo ${n} ${cmp}

    for test in allreduce allgather alltoall; do

	case "$test" in
	    allreduce)
	        nccltest="all_reduce"
		;;
	    allgather)
		nccltest="all_gather"
		;;
	    alltoall)
		nccltest="alltoall"
		;;
	    *)
		echo "unknown op: $test" >&2
		exit 1
		;;
	esac

	case "${SYSTEM}" in
	    lumi)

		FILES=("$(ls ../osu/craype/collectives/lumi/osu_${test}_i_100_d_rocm_D_D_n${n}_hybrid_*.txt)"
		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_${test}_d_rocm_D_D_${cmp}_n${n}_${TAGMODE}*.txt)"
		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_${test}_d_rocm_D_D_lnx_n${n}_software_*.txt)"
#		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_xccl_${test}_d_rocm_D_D_n${n}_hybrid_*.txt)"
		       "$(ls ../osu/ompi/collectives/lumi_opt1/${nccltest}_perf_d_uint8_b_1_e_128M_f_2_g_1_n${n}_hybrid_*.txt)"
		       "../osu/ompi/collectives/lumi_marcin_6.x/osu_${test}_d_rocm_lnx_n${n}.txt"
		      )
	    ;;
	    olivia)

		FILES=("craype/collectives/olivia/osu_${test}_d_cuda_n${n}.txt"
		       "ompi/collectives/olivia/osu_${test}_d_cuda_n${n}_${cmp}_srun.txt"
		       "ompi/collectives/olivia/osu_${test}_d_cuda_n${n}_lnx_srun.txt"
		       #       "ompi/collectives/olivia/ompi6/osu_xccl_${test}_n${n}_srun.txt"
		       "ompi/collectives/olivia/osu_xccl_${test}_n${n}_srun.txt"
		       #       "craype/collectives/olivia/osu_xccl_${test}_n${n}.txt"
		       "ompi/nccl/olivia/${nccltest}_perf_n${n}.txt"
		       #       "craype/collectives/olivia/all_reduce_perf_n${n}.txt"
		       "ompi/collectives/olivia/ompi6/osu_${test}_d_cuda_n${n}_${cmp}_srun.txt"
		       #       "ompi/collectives/olivia/ompi6_coll_accelerator_off/osu_${test}_d_cuda_n${n}_${cmp}_srun.txt"
		      )
		;;
	esac

	LABELS=("Cray MPI"
		"ompi5 ${cmp}"
		"ompi5 lnx"
#		"${XCCL} (OSU)"
		"${XCCL} (${XCCL_TESTS})"
		"ompi6 ${cmp}"
	       )
	STYLES=("b-o"
		"g-^"
		"g-o"
#		"ro:"
		"r^:"
		"k-o"
	       )
#	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "${test} Device, ${n} GPUs" --outfile ${SYSTEM}/osu-${test}_n${n}_${suffix}.png
	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "" --outfile ${SYSTEM}/osu-${test}_n${n}_${suffix}.png
    done
done

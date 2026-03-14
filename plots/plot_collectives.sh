#!/bin/bash

#MYUSER="marcink"
MYUSER="alazzaro"
#MYUSER=${MYUSER:-${USER}}

for MYUSER in marcink; do
#for MYUSER in alazzaro; do

echo "User: $MYUSER"

case "$MYUSER" in
    lazzaroa|alazzaro)
	SYSTEM="lumi"
	suffix="amd"
	NGPUS="8 128 512"
	NGPUS_PER_NODE=8
	XCCL="RCCL"
	XCCL_TESTS="rccl-tests"
	;;
    marcink)
	SYSTEM="olivia"
	suffix="cuda"
	NGPUS="4 64"
	NGPUS_PER_NODE=4
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

		FILES=("$(ls ../osu/craype/collectives/lumi_opt1/osu_${test}_i_100_d_rocm_D_D_n${n}_hybrid_*.txt)"
		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_${test}_d_rocm_D_D_${cmp}_n${n}_${TAGMODE}*.txt)"
		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_${test}_d_rocm_D_D_lnx_n${n}_software_*.txt)"
#		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_xccl_${test}_d_rocm_D_D_n${n}_hybrid_*.txt)"
#		       "$(ls ../osu/craype/collectives/lumi_rccl/${nccltest}_perf_d_int8_b_1_e_128M_f_2_g_1_n${n}_hybrid_*.txt)"
#		       "$(ls ../osu/craype/collectives/lumi/${nccltest}_perf_d_uint8_b_1_e_128M_f_2_g_1_n${n}_hybrid_*.txt)"
		       "$(ls ../osu/craype/collectives/lumi_opt1_rccl/${nccltest}_perf_d_int8_b_1_e_128M_f_2_g_1_n${n}_hybrid_*.txt)"
		       "../osu/ompi/collectives/lumi_marcin_6.x/osu_${test}_d_rocm_lnx_n${n}.txt"
		      )
	    ;;
	    olivia)

		if [[ ${n} == 4 ]]; then
		    FILES=("../osu/craype/collectives/olivia/osu_${test}_d_cuda_n${n}.txt"
			   "../osu/ompi/collectives/olivia/cxi_hmem_on/osu_${test}_d_cuda_n${n}_cxi_srun.txt"
			   "../osu/ompi/collectives/olivia/osu_${test}_d_cuda_n${n}_lnx_srun.txt"
			   "../osu/ompi/collectives/olivia/osu_${test}_d_cuda_n${n}_ob1_srun.txt"
			   "../osu/ompi/nccl/olivia/${nccltest}_perf_n${n}.txt"
#			   "../osu/ompi/collectives/olivia/ompi6/osu_${test}_d_cuda_n${n}_${cmp}_srun.txt"
#			   "../osu/ompi/collectives/olivia/cxi_hmem_on/ompi6/osu_${test}_d_cuda_n${n}_ob1_srun.txt"
#			   "../osu/ompi/collectives/olivia/cxi_hmem_on/ompi6/osu_${test}_d_cuda_n${n}_lnx_srun.txt"
			   "../osu/ompi/collectives/olivia/cxi_hmem_on/ompi6/osu_${test}_d_cuda_n${n}_cxi_srun.txt"
			  )
		    LABELS=("Cray MPI"
			    "ompi5 cxi"
			    "ompi5 lnx"
			    "ompi5 ob1"
			    "${XCCL} (${XCCL_TESTS})"
			    "ompi6 ${cmp}"
			   )
		    STYLES=("b-o"
			    "g-^"
			    "g-o"
			    "g--s"
			    "r^:"
			    "k-o"
			   )
		else
		    FILES=("../osu/craype/collectives/olivia/osu_${test}_d_cuda_n${n}.txt"
			   "../osu/ompi/collectives/olivia/cxi_hmem_on/osu_${test}_d_cuda_n${n}_cxi_srun.txt"
			   "../osu/ompi/collectives/olivia/osu_${test}_d_cuda_n${n}_lnx_srun.txt"
			   "../osu/ompi/nccl/olivia/${nccltest}_perf_n${n}.txt"
#			   "../osu/ompi/collectives/olivia/ompi6/osu_${test}_d_cuda_n${n}_${cmp}_srun.txt"
			   "../osu/ompi/collectives/olivia/cxi_hmem_on/ompi6/osu_${test}_d_cuda_n${n}_cxi_srun.txt"
			  )
		    LABELS=("Cray MPI"
			    "ompi5 cxi"
			    "ompi5 lnx"
			    "${XCCL} (${XCCL_TESTS})"
			    "ompi6 ${cmp}"
			   )
		    STYLES=("b-o"
			    "g-^"
			    "g-o"
			    "r^:"
			    "k-o"
			   )
		fi		
		;;
	esac

	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "${test} Device, $((n / NGPUS_PER_NODE)) nodes" --outfile ${SYSTEM}/osu-${test}_n${n}_${suffix}.png
    done
done

done # MYUSER

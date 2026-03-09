#!/bin/bash

for n in 4 64; do
    cmp='cxi'
    if [[ ${n} == 4 ]]; then
	cmp='ob1'
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
	LABELS=("Cray MPI"
		"ompi5 ${cmp}"
		"ompi5 lnx"
		"NCCL (OSU)"
		"NCCL (nccl-tests)"
		"ompi6 ${cmp}"
	       )
	STYLES=("b-o"
		"g-^"
		"g-o"
		"r^:"
		"ro:"
		"k-o"
	       )
	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "${test} Device, ${n} GPUs" --outfile osu-${test}_n${n}_cuda.png
    done
done

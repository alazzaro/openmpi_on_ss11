#!/bin/bash
if false; then
for d in `ls ../osu/ompi/nccl/olivia/nccl_stability_test/`; do
    echo $d
    for test in all_gather_perf all_reduce_perf  alltoall_perf; do
	FILES=("../osu/ompi/nccl/olivia/nccl_stability_test/$d/1/${test}_n64.txt"
	       "../osu/ompi/nccl/olivia/nccl_stability_test/$d/2/${test}_n64.txt"
	       "../osu/ompi/nccl/olivia/nccl_stability_test/$d/3/${test}_n64.txt"
	       "../osu/ompi/nccl/olivia/nccl_stability_test/$d/4/${test}_n64.txt"
	       "../osu/ompi/nccl/olivia/nccl_stability_test/$d/5/${test}_n64.txt"
	      )
	LABELS=("1"
		"2"
		"3"
		"4"
		"5"
	       )
	STYLES=("b-o"
		"g-^"
		"g-o"
		"r^:"
		"ro:"
	       )
	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "$test $d" --outfile ${test}_${d}.png
    done
done
fi

for test in all_gather_perf all_reduce_perf  alltoall_perf; do
    FILES=("../osu/ompi/nccl/olivia/nccl_stability_test/float_crossnic0/1/${test}_n64.txt"
	   "../osu/ompi/nccl/olivia/nccl_stability_test/float_crossnic1/2/${test}_n64.txt"
	   "../osu/ompi/nccl/olivia/nccl_stability_test/int8_crossnic0/3/${test}_n64.txt"
	   "../osu/ompi/nccl/olivia/nccl_stability_test/int8_crossnic1/4/${test}_n64.txt"
	  )
    LABELS=("float_crossnic0"
	    "float_crossnic1"
	    "int8_crossnic0"
	    "int8_crossnic1"
	   )
    STYLES=("b-o"
	    "g-^"
	    "r-o"
	    "k-^"
	   )
    ./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "$test $d" --outfile ${test}_types_performance.png
done

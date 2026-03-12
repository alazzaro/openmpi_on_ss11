#!/bin/bash

#MYUSER="marcink"
MYUSER="alazzaro"
#MYUSER=${MYUSER:-${USER}}

echo "User: $MYUSER"

case "$MYUSER" in
    lazzaroa|alazzaro)
	DIRECTORY="../osu/craype/collectives/lumi_opt1_rccl"
        NGPUS="128"
	DIR_SUFFIX="rccl_"
        ;;
    marcink)
	DIRECTORY="../osu/ompi/nccl/olivia/nccl_stability_test/*"
        NGPUS="64"
	DIR_SUFFIX=""
        ;;
    *)
        echo "User not recongnized"
        exit -1
esac



#if false; then
for d in `ls -d ${DIRECTORY}`; do
    echo $d
    for test in all_gather_perf all_reduce_perf  alltoall_perf; do
	ls ${d}/${DIR_SUFFIX}1/${test}*_n${NGPUS}*.txt
	FILES=("$(ls ${d}/${DIR_SUFFIX}1/${test}*_n${NGPUS}*.txt)"
	       "$(ls ${d}/${DIR_SUFFIX}2/${test}*_n${NGPUS}*.txt)"
	       "$(ls ${d}/${DIR_SUFFIX}3/${test}*_n${NGPUS}*.txt)"
	       "$(ls ${d}/${DIR_SUFFIX}4/${test}*_n${NGPUS}*.txt)"
	       "$(ls ${d}/${DIR_SUFFIX}5/${test}*_n${NGPUS}*.txt)"
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
	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "$test `basename $d`" --outfile ${test}_`basename ${d}`.png
    done
done
#fi

if false; then
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
fi

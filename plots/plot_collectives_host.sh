#!/bin/bash

for n in 4 64; do
    cmp='cxi'
    if [[ ${n} == 4 ]]; then
	cmp='ob1'
    fi
    echo ${n} ${cmp}

    for test in allreduce allgather alltoall; do
	FILES=("craype/collectives/olivia/osu_${test}_n${n}.txt"
	       "ompi/collectives/olivia/osu_${test}_n${n}_${cmp}_srun.txt"
	       "ompi/collectives/olivia/osu_${test}_n${n}_lnx_srun.txt"
	       "ompi/collectives/olivia/ompi6/osu_${test}_n${n}_${cmp}_srun.txt"
	      )
	LABELS=("Cray MPI"
		"ompi5 ${cmp}"
		"ompi5 lnx"
		"ompi6 ${cmp}"
	       )
	STYLES=("b-o"
		"g-^"
		"g-o"
		"k-o"
	       )
	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "${test} Host, ${n} GPUs" --outfile osu-${test}_n${n}_host.png
    done
done

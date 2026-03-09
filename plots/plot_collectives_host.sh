#!/bin/bash

#MYUSER="marcink"
#MYUSER="alazzaro"
MYUSER=${MYUSER:-${USER}}

echo "User: $MYUSER"

case "$MYUSER" in
    lazzaroa|alazzaro)
	SYSTEM="lumi"
	NGPUS="8 64"
	;;
    marcink)
	SYSTEM="olivia"
	NGPUS="4 64"
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


	case "${SYSTEM}" in
	    lumi)

		FILES=("$(ls ../osu/craype/collectives/lumi/osu_${test}_i_100_H_H_n${n}_hybrid_*.txt)"
		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_${test}_H_H_${cmp}_n${n}_${TAGMODE}*.txt)"
		       "$(ls ../osu/ompi/collectives/lumi_opt1/osu_${test}_H_H_lnx_n${n}_software_*.txt)"
		      )

		# Remove OpenMPI 6
		unset LABELS[3]
		unset STYLES[3]

	    ;;
	    olivia)

		FILES=("craype/collectives/olivia/osu_${test}_n${n}.txt"
		       "ompi/collectives/olivia/osu_${test}_n${n}_${cmp}_srun.txt"
		       "ompi/collectives/olivia/osu_${test}_n${n}_lnx_srun.txt"
		       "ompi/collectives/olivia/ompi6/osu_${test}_n${n}_${cmp}_srun.txt"
		      )
		;;
	esac

	./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "${test} Host, ${n} GPUs" --outfile ${SYSTEM}/osu-${test}_n${n}_host.png
    done
done

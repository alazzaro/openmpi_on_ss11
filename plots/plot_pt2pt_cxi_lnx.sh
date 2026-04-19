#!/bin/bash

MYUSER="marcink"
#MYUSER="alazzaro"
#MYUSER=${MYUSER:-${USER}}

PYTHON="python3.14"

echo "User: $MYUSER"

case "$MYUSER" in
    lazzaroa|alazzaro)
        SYSTEM="lumi"
	PYTHON="python3.14"
        ;;
    marcink)
        SYSTEM="olivia"
        ;;
    *)
        echo "User not recongnized"
        exit -1
esac

mkdir -p ${SYSTEM}

case "${SYSTEM}" in
    lumi)

	FILES=("../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_ob1_singlenode_16489870_mpirun.txt"
	       "../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_lnx_singlenode_hybrid_16489870_mpirun.txt"
	       "../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_cxi_singlenode_hybrid_17528243_mpirun.txt"
	       "../osu/slingshot11_peak_bibw.txt"
	      )

	LABELS=("ompi ob1"
		"ompi lnx (shm)"
		"ompi cxi"
		"SS11 peak bibw"
       )

    ;;

    olivia)

	FILES=("../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_ob1_srun.txt"
	       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_lnx_srun.txt"
	       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_cxi_srun.txt"
	       "../osu/slingshot11_peak_bibw.txt"
	      )

	LABELS=("ompi ob1"
		"ompi lnx (shm)"
		"ompi cxi"
		"SS11 peak bibw"
	       )
	;;
esac




STYLES=("b-o"
	"r-o"
	"g-o"
	"k-"
       )

# ${PYTHON} ./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw HH" --outfile ${SYSTEM}/osu-internode-bibw-all-HH.png
${PYTHON} ./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "" --outfile ${SYSTEM}/osu-intranode-cxi-vs-lnx.png

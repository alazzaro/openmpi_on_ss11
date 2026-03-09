#!/bin/bash

#MYUSER="marcink"
#MYUSER="alazzaro"
MYUSER=${MYUSER:-${USER}}

echo "User: $MYUSER"

case "$MYUSER" in
    lazzaroa|alazzaro)
        SYSTEM="lumi"
	XCCL="RCCL"
        ;;
    marcink)
        SYSTEM="olivia"
	 XCCL="NCCL"
        ;;
    *)
        echo "User not recongnized"
        exit -1
esac

mkdir -p ${SYSTEM}

LABELS=("Cray MPI (-b multiple)"
	"Cray MPI (-b single)"
	"ompi ob1"
	"ompi lnx"
	"OSU + ${XCCL}"
       )
STYLES=("b-o"
	"bo:"
	"g-^"
	"g-o"
	"r^:"
       )

case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi_single_buffer/osu_bibw_b_single_d_rocm_D_D_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_ob1_singlenode_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_lnx_singlenode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_xccl_bibw_b_multiple_d_rocm_D_D_singlenode_hybrid_*.txt)"
		      )
	    ;;
	    olivia)
		FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode.txt"
		       "craype/pt2pt/olivia/osu_bibw_b_single_D_D_singlenode.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_ob1_srun.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_lnx_srun.txt"
		       "craype/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_singlenode.txt"
		      )
		;;
esac

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU intra-node bibw DD" --outfile $SYSTEM/osu-intranode-bibw-DD.png

case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_cxi_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_lnx_multinode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_xccl_bibw_b_multiple_d_rocm_D_D_multinode_hybrid_*.txt)"
		      )
	    ;;
	    olivia)
		# here cray -b multiple is fine, so it's only intranode that is borken
		# lnx perf drop for mid-size messages due to software matching. need another plot to show this with cxi
		FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_lnx_srun.txt"
		       "craype/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_multinode.txt"
		      )
		;;
esac

LABELS=("Cray MPI (-b multiple)"
	"ompi cxi"
	"ompi lnx"
	"OSU + ${XCCL}"
       )
STYLES=("b-o"
	"g-^"
	"g-o"
	"r^:"
       )

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw DD" --outfile ${SYSTEM}/osu-internode-bibw-DD.png


case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_cxi_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_cxi_multinode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_lnx_multinode_software_*.txt)"
		      )
	    ;;
	    olivia)
		FILES=("ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
		       "ompi/pt2pt/olivia/software_matching/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_lnx_srun.txt"
		      )
		;;
esac

LABELS=("ompi cxi, hybrid matching"
	"ompi cxi, software matching"
	"ompi lnx"
       )
STYLES=("g-^"
	"r-^"
	"g-o"
       )

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw DD" --outfile ${SYSTEM}/osu-internode-bibw-tagmatching-DD.png


case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_H_H_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi_single_buffer/osu_bibw_b_single_H_H_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_ob1_singlenode_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_lnx_singlenode_software*.txt)"
		)
	    ;;
	    olivia)

		FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode.txt"
		       "craype/pt2pt/olivia/osu_bibw_b_single_H_H_singlenode.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_ob1_srun.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_lnx_srun.txt"
		      )
		;;
esac

LABELS=("Cray MPI (-b multiple)"
	"Cray MPI (-b single)"
	"ompi ob1"
	"ompi lnx"
       )
STYLES=("b-o"
	"bo:"
	"g-^"
	"g-o"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU intra-node bibw HH" --outfile ${SYSTEM}/osu-intranode-bibw-HH.png

case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_H_H_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_cxi_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_lnx_multinode_software_*.txt)"
		      )
		;;
	    olivia)

		FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_lnx_srun.txt"
		      )
		;;
esac

LABELS=("Cray MPI (-b multiple)"
	"ompi cxi"
	"ompi lnx"
       )
STYLES=("b-o"
	"g-^"
	"g-o"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw HH" --outfile ${SYSTEM}/osu-internode-bibw-HH.png

case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_cxi_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_cxi_multinode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_lnx_multinode_software_*.txt)"
		      )
	    ;;
	    olivia)

		FILES=("ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
		       "ompi/pt2pt/olivia/software_matching/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
		       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_lnx_srun.txt"
		      )
		;;
esac

LABELS=("ompi cxi, hybrid matching"
	"ompi cxi, software matching"
	"ompi lnx"
       )
STYLES=("g-^"
	"r-^"
	"g-o"
       )

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw HH" --outfile ${SYSTEM}/osu-internode-bibw-tagmatching-HH.png

#!/bin/bash

MYUSER="marcink"
#MYUSER="alazzaro"
#MYUSER=${MYUSER:-${USER}}

for MYUSER in alazzaro marcink; do

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
	"Cray MPI (-b multiple) IPC opt"
	"Cray MPI (-b single) IPC opt"
	"ompi ob1"
	"ompi lnx"
	"OSU + ${XCCL}"
       )
STYLES=("b-o"
	"bo:"
	"k-^"
	"k^:"
	"g-^"
	"g-o"
	"r^:"
       )

case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi_single_buffer/osu_bibw_b_single_d_rocm_D_D_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi_ipc_opt/osu_bibw_b_multiple_d_rocm_D_D_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi_ipc_opt/osu_bibw_b_single_d_rocm_D_D_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_ob1_singlenode_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_lnx_singlenode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_xccl_bibw_b_multiple_d_rocm_D_D_singlenode_hybrid_*.txt)"
		      )
	    ;;
	    olivia)
		FILES=("../osu/craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode.txt"
		       "../osu/craype/pt2pt/olivia/osu_bibw_b_single_D_D_singlenode.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_ob1_srun.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_lnx_srun.txt"
		       "../osu/ompi/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_singlenode_mpirun.txt"
		      )
		unset LABELS[2]
		unset LABELS[3]
		unset STYLES[2]
		unset STYLES[3]
		;;
esac

#./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU intra-node bibw DD" --outfile $SYSTEM/osu-intranode-bibw-DD.png
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "" --outfile $SYSTEM/osu-intranode-bibw-DD.png


case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_H_H_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi_single_buffer/osu_bibw_b_single_H_H_singlenode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_ob1_singlenode_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_lnx_singlenode_software*.txt)"
		)
	    ;;
	    olivia)

		FILES=("../osu/craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode.txt"
		       "../osu/craype/pt2pt/olivia/osu_bibw_b_single_H_H_singlenode.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_ob1_srun.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_lnx_srun.txt"
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
#./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU intra-node bibw HH" --outfile ${SYSTEM}/osu-intranode-bibw-HH.png
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "" --outfile ${SYSTEM}/osu-intranode-bibw-HH.png


case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_H_H_multinode_hybrid_*.txt)"
#		       "$(ls ../osu/craype/pt2pt/lumi_single_buffer/osu_bibw_b_single_H_H_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_cxi_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_cxi_multinode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_H_H_lnx_multinode_software_*.txt)"
		       "../osu/slingshot11_peak_bibw.txt"
		      )
	    ;;
	    olivia)

		FILES=("../osu/craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
		       "../osu/ompi/pt2pt/olivia/software_matching/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_lnx_srun.txt"
		       "../osu/slingshot11_peak_bibw.txt"
		      )
		;;
esac

LABELS=("Cray MPI (-b multiple)"
#	"Cray MPI (-b single)"
	"ompi cxi, hybrid matching"
	"ompi cxi, software matching"
	"ompi lnx"
	"SS11 peak bibw"
       )
STYLES=("b-o"
#	"bo:"
	"g-^"
	"r-^"
	"g-o"
	"k-"
       )

#./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw HH" --outfile ${SYSTEM}/osu-internode-bibw-all-HH.png
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "" --outfile ${SYSTEM}/osu-internode-bibw-all-HH.png


LABELS=("Cray MPI (-b multiple), hybrid matching"
	"Cray MPI (-b multiple), software matching"
	"ompi cxi, hybrid matching"
	"ompi cxi, software matching"
	"ompi lnx"
	"OSU + ${XCCL}"
	"SS11 peak bibw"
       )
STYLES=("b-o"
	"bo:"
	"g-^"
	"r-^"
	"g-o"
	"r^:"
	"k-"
       )


case "${SYSTEM}" in
            lumi)
		FILES=("$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_multinode_hybrid_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_multinode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_cxi_multinode_hybrid_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_cxi_multinode_software_*.txt)"
		       "$(ls ../osu/ompi/pt2pt/lumi/osu_bibw_b_multiple_d_rocm_D_D_lnx_multinode_software_*.txt)"
		       "$(ls ../osu/craype/pt2pt/lumi/osu_xccl_bibw_b_multiple_d_rocm_D_D_multinode_hybrid_*.txt)"
		       "../osu/slingshot11_peak_bibw.txt"
		      )
	    ;;
	    olivia)
		FILES=("../osu/craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode.txt"
		       "../osu/craype/pt2pt/olivia/cxi_software_matching/osu_bibw_b_multiple_D_D_multinode.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
		       "../osu/ompi/pt2pt/olivia/software_matching/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
		       "../osu/ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_lnx_srun.txt"
		       "../osu/craype/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_multinode.txt"
		       "../osu/slingshot11_peak_bibw.txt"
		      )
		;;
esac

#./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw DD" --outfile ${SYSTEM}/osu-internode-bibw-all-DD.png
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "" --outfile ${SYSTEM}/osu-internode-bibw-all-DD.png

done # MYUSER

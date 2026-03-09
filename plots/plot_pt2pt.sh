#!/bin/bash

FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode.txt"
       "craype/pt2pt/olivia/osu_bibw_b_single_D_D_singlenode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_ob1_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_lnx_srun.txt"
       "craype/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_singlenode.txt"
      )
LABELS=("Cray MPI (-b multiple)"
	"Cray MPI (-b single)"
	"ompi ob1"
	"ompi lnx"
	"OSU + NCCL"
       )
STYLES=("b-o"
	"bo:"
	"g-^"
	"g-o"
	"r^:"
       )

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU intra-node bibw DD" --outfile osu-intranode-bibw-DD.png

# here cray -b multiple is fine, so it's only intranode that is borken
# lnx perf drop for mid-size messages due to software matching. need another plot to show this with cxi
FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_lnx_srun.txt"
       "craype/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_multinode.txt"
      )
LABELS=("Cray MPI (-b multiple)"
	"ompi cxi"
	"ompi lnx"
	"OSU + NCCL"
       )
STYLES=("b-o"
	"g-^"
	"g-o"
	"r^:"
       )

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw DD" --outfile osu-internode-bibw-DD.png

FILES=("ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
       "ompi/pt2pt/olivia/software_matching/osu_bibw_b_multiple_D_D_multinode_cxi_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_lnx_srun.txt"
      )
LABELS=("ompi cxi, hybrid matching"
	"ompi cxi, software matching"
	"ompi lnx"
       )
STYLES=("g-^"
	"r-^"
	"g-o"
       )

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw DD" --outfile osu-internode-bibw-tagmatching-DD.png


FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode.txt"
       "craype/pt2pt/olivia/osu_bibw_b_single_H_H_singlenode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_ob1_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_lnx_srun.txt"
      )
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
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU intra-node bibw HH" --outfile osu-intranode-bibw-HH.png


FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_lnx_srun.txt"
      )
LABELS=("Cray MPI (-b multiple)"
	"ompi cxi"
	"ompi lnx"
       )
STYLES=("b-o"
	"g-^"
	"g-o"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw HH" --outfile osu-internode-bibw-HH.png

FILES=("ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
       "ompi/pt2pt/olivia/software_matching/osu_bibw_b_multiple_H_H_multinode_cxi_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_lnx_srun.txt"
      )
LABELS=("ompi cxi, hybrid matching"
	"ompi cxi, software matching"
	"ompi lnx"
       )
STYLES=("g-^"
	"r-^"
	"g-o"
       )

./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "OSU inter-node bibw HH" --outfile osu-internode-bibw-tagmatching-HH.png

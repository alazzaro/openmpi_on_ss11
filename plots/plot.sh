#!/bin/bash

FILES=("craype/collectives/olivia/tuning/osu_allreduce_d_cuda_n64.txt"
       "ompi/collectives/olivia/osu_allreduce_d_cuda_n64_cxi_srun.txt"
       "ompi/collectives/olivia/osu_allreduce_d_cuda_n64_lnx_srun.txt"
       "ompi/collectives/olivia/ompi6/osu_xccl_allreduce_n64_srun.txt"
       "ompi/collectives/olivia/osu_xccl_allreduce_n64_srun.txt"
#       "craype/collectives/olivia/osu_xccl_allreduce_n64.txt"
#       "craype/collectives/olivia/all_reduce_perf_n64.txt"
       "ompi/collectives/olivia/ompi6/osu_allreduce_d_cuda_n64_cxi_srun.txt"
      )
LABELS=("Cray MPI"
	"ompi5 cxi"
	"ompi5 lnx"
	"osu NCCL"
	"nccl-tests NCCL"
	"ompi6 cxi"
       )
STYLES=("b-o"
	"g-^"
	"g-o"
	"r^:"
	"ro:"
	"k-o"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "allreduce Device, 64 GPUs" --outfile osu-allreduce_n64_cuda.png

FILES=("craype/collectives/olivia/tuning/osu_allgather_d_cuda_n64.txt"
       "ompi/collectives/olivia/osu_allgather_d_cuda_n64_cxi_srun.txt"
       "ompi/collectives/olivia/osu_allgather_d_cuda_n64_lnx_srun.txt"
       "ompi/collectives/olivia/ompi6/osu_xccl_allgather_n64_srun.txt"
       "ompi/collectives/olivia/osu_xccl_allgather_n64_srun.txt"
#       "craype/collectives/olivia/osu_xccl_allgather_n64.txt"
#       "craype/collectives/olivia/all_gather_perf_n64.txt"
       "ompi/collectives/olivia/ompi6/osu_allgather_d_cuda_n64_cxi_srun.txt"
      )
LABELS=("Cray MPI"
	"ompi5 cxi"
	"ompi5 lnx"
	"osu NCCL"
	"nccl-tests NCCL"
	"ompi6 cxi"
       )
STYLES=("b-o"
	"g-^"
	"g-o"
	"r^:"
	"ro:"
	"k-o"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "allgather Device, 64 GPUs" --outfile osu-allgather_n64_cuda.png

FILES=("craype/collectives/olivia/tuning/osu_alltoall_d_cuda_n64.txt"
       "ompi/collectives/olivia/osu_alltoall_d_cuda_n64_cxi_srun.txt"
       "ompi/collectives/olivia/osu_alltoall_d_cuda_n64_lnx_srun.txt"
       "ompi/collectives/olivia/ompi6/osu_xccl_alltoall_n64_srun.txt"
       "ompi/collectives/olivia/osu_xccl_alltoall_n64_srun.txt"
#       "craype/collectives/olivia/osu_xccl_alltoall_n64.txt"
#       "craype/collectives/olivia/alltoall_perf_n64.txt"
       "ompi/collectives/olivia/ompi6/osu_alltoall_d_cuda_n64_cxi_srun.txt"
      )
LABELS=("Cray MPI"
	"ompi5 cxi"
	"ompi5 lnx"
	"osu NCCL"
	"nccl-tests NCCL"
	"ompi6 cxi"
       )
STYLES=("b-o"
	"g-^"
	"g-o"
	"r^:"
	"ro:"
	"k-o"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --styles "${STYLES[@]}" --title "alltoall Device, 64 GPUs" --outfile osu-alltoall_n64_cuda.png

exit 0

FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode.txt"
       "craype/pt2pt/olivia/osu_bibw_b_single_D_D_singlenode.txt"
       "craype/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_singlenode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_lnx_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_singlenode_ob1_srun.txt"
      )
LABELS=("Cray MPI (-b multiple)"
	"Cray MPI (-b single)"
	"Cray MPI + OSU NCCL"
	"ompi lnx"
	"ompi ob1"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --title "OSU intra-node bibw DD" --outfile osu-intranode-bibw.png


FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode.txt"
       "craype/pt2pt/olivia/osu_bibw_b_single_D_D_multinode.txt"
       "craype/pt2pt/olivia/osu_xccl_bibw_b_multiple_D_D_multinode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_lnx_mpirun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_D_D_multinode_cxi_mpirun.txt"
      )
LABELS=("Cray MPI (-b multiple)"
	"Cray MPI (-b single)"
	"Cray MPI + OSU NCCL"
	"ompi lnx"
	"ompi cxi"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --title "OSU inter-node bibw DD" --outfile osu-internode-bibw.png


FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode.txt"
       "craype/pt2pt/olivia/osu_bibw_b_single_H_H_singlenode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_lnx_srun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_singlenode_ob1_srun.txt"
      )
LABELS=("Cray MPI (-b multiple)"
	"Cray MPI (-b single)"
	"ompi lnx"
	"ompi ob1"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --title "OSU intra-node bibw HH" --outfile osu-intranode-bibw-HH.png


FILES=("craype/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode.txt"
       "craype/pt2pt/olivia/osu_bibw_b_single_H_H_multinode.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_lnx_mpirun.txt"
       "ompi/pt2pt/olivia/osu_bibw_b_multiple_H_H_multinode_cxi_mpirun.txt"
      )
LABELS=("Cray MPI (-b multiple)"
	"Cray MPI (-b single)"
	"ompi lnx"
	"ompi cxi"
       )
./plot.py --files "${FILES[@]}" --labels "${LABELS[@]}" --title "OSU inter-node bibw HH" --outfile osu-internode-bibw-HH.png


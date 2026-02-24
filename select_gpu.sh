#!/bin/bash

GPUSID="4 5 2 3 6 7 0 1"
GPUSID=(${GPUSID})

LOCALID=0
NTASKS_PER_NODE=1
if [ "$OMPI_COMM_WORLD_LOCAL_RANK" ]; then
    LOCALID=$OMPI_COMM_WORLD_LOCAL_RANK
    NTASKS_PER_NODE=$OMPI_COMM_WORLD_LOCAL_SIZE

#    CXISID="2 1 3 0"
#    CXISID=(${CXISID})
#    # For multi-NIC systems set the NIC you want
#    if [ ${NTASKS_PER_NODE} -lt ${#CXISID[@]} ]; then
#	CXI=${CXISID[$LOCALID]}
#    else
#	CXI=${CXISID[$((LOCALID / ($NTASKS_PER_NODE / ${#CXISID[@]})))]}
#    fi
#    export FI_CXI_DEVICE_NAME="cxi$CXI"
#
#    echo $LOCALID cxi $FI_CXI_DEVICE_NAME $NTASKS_PER_NODE

elif [ "$SLURM_LOCALID" ]; then
    LOCALID=$SLURM_LOCALID
    NTASKS_PER_NODE=$SLURM_NTASKS_PER_NODE
else
    echo "No env variables!"
    exit -1
fi

if [ ${#GPUSID[@]} -le ${NTASKS_PER_NODE} ]; then
    export HIP_VISIBLE_DEVICES=${GPUSID[$((LOCALID / ($NTASKS_PER_NODE / ${#GPUSID[@]})))]}
else
    export HIP_VISIBLE_DEVICES=${GPUSID[$LOCALID]}
fi

#echo $LOCALID gpu $HIP_VISIBLE_DEVICES $NTASKS_PER_NODE

exec $*

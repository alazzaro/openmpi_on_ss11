#!/bin/bash -x

set -e

##### env and modules ###

source sourceme_nccl.sh

### Delete previous installation

rm -rf $NCCL_DIR
rm -rf $PREFIX_NCCL

### Install nccl 2.29.2
cd $ROOT_DIR
mkdir -p $NCCL_DIR
mkdir -p $PREFIX_NCCL
cd $NCCL_DIR

VER=2.29.2
wget https://github.com/NVIDIA/nccl/archive/refs/tags/v${VER}-1.tar.gz
tar xvf v${VER}-1.tar.gz
cd nccl-${VER}-1

make -j src.build NVCC_GENCODE="-gencode=arch=compute_90,code=sm_90" CC=cc CXX=CC
mv build/* $PREFIX_NCCL
cd ..

### Install and aws plugin 1.17.3
VER=1.17.3
wget https://github.com/aws/aws-ofi-nccl/releases/download/v${VER}/aws-ofi-nccl-${VER}.tar.gz
tar xaf aws-ofi-nccl-${VER}.tar.gz
cd aws-ofi-nccl-${VER}
./configure --prefix=${PREFIX_NCCL} --with-cuda=${CUDA_HOME} --with-libfabric=${PREFIX_LIBFABRIC} 
make -j install
cd ..

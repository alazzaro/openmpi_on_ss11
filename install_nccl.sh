#!/bin/bash -x

set -e

##### env and modules ###

export GPU_ACCL=nccl
source sourceme_nccl.sh

## Check if CUDA is available for compilation
if [[ -z "$CUDA_HOME" ]]; then
    echo "ERROR: CUDA_HOME is not set"
    echo ""
    echo "NCCL compilation requires CUDA development tools."
    echo "On this system, CUDA may only be available on compute nodes."
    echo ""
    echo "Solutions:"
    echo "1. Set CUDA_HOME manually if you know the CUDA installation path:"
    echo "   export CUDA_HOME=/path/to/cuda"
    echo "2. Submit this build script as a job to run on a compute node with GPU"
    echo "3. Use a pre-compiled NCCL module if available:"
    echo "   module load NCCL"
    echo "4. Build NCCL in an interactive session on a compute node:"
    echo "   salloc -N 1 --partition=gpu"
    echo ""
    exit 1
fi

echo "Using CUDA installation: $CUDA_HOME"

# Check if CUDA compiler is available
if ! command -v nvcc &> /dev/null; then
    echo "WARNING: nvcc (NVIDIA CUDA Compiler) not found in PATH"
    echo "NCCL compilation may fail"
    echo "Add CUDA bin directory to PATH: export PATH=\$CUDA_HOME/bin:\$PATH"
fi

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

make -j src.build NVCC_GENCODE="-gencode=arch=compute_90,code=sm_90"
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

# to compile OSU with NCCL support:
# - with cray mpi
# ./configure CC=cc CXX=CC --prefix=$PREFIX_OSU/osu-craype/ --with-cuda=${CUDA_HOME} --with-nccl=${PREFIX_NCCL} --enable-ncclomb --with-cuda-include=${CUDA_HOME}/include --with-cuda-libpath=${CUDA_HOME}/targets/x86_64-linux/lib
#
# - with OpenMPI
# ./configure CC=mpicc CXX=mpicxx --prefix=$PREFIX_OSU/osu-ompi/ --with-cuda=${CUDA_HOME} --with-nccl=$NCCL_HOME --enable-ncclomb --with-cuda-include=${CUDA_HOME}/include --with-cuda-libpath=${CUDA_HOME}/targets/x86_64-linux/lib

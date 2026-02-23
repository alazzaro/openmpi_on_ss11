#!/bin/bash -x

set -e

##### env and modules ###

source sourceme_ompi.sh

### Delete previous installation

rm -rf $PREFIX_OMPI
rm -rf $OMPI_DIR

### Install OpenMPI 5.0.9 https://github.com/open-mpi/ompi

cd $ROOT_DIR
mkdir -p $OMPI_DIR
cd $OMPI_DIR
VER=5.0.9
wget https://download.open-mpi.org/release/open-mpi/v5.0/openmpi-${VER}.tar.bz2
tar xvf openmpi-${VER}.tar.bz2
cd openmpi-${VER}
./configure --prefix=$PREFIX_OMPI ${XPMEM_OMPI} ${GPU_OMPI} \
            --without-ucx \
            --with-ofi=${PREFIX_LIBFABRIC} \
            --without-lsf --with-slurm --with-pmix=internal \
            --without-knem --with-libevent=internal --with-hwloc=internal \
            --enable-mca-no-build=btl-usnic \
            2>&1 | tee configure.log
make -j 10 install 2>&1 | tee make.log

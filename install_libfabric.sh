#!/bin/bash -x

set -e

##### env and modules ###

source sourceme_libfabric.sh

### Delete previous installation

rm -rf $PREFIX_CXI
rm -rf $PREFIX_LIBFABRIC
rm -rf $LIBFABRIC_DIR

### Install LIBCXI dependencies ###

# Libconfig https://github.com/hyperrealm/libconfig

cd $ROOT_DIR
mkdir -p $LIBCXI_DIR
cd $LIBCXI_DIR
wget https://github.com/hyperrealm/libconfig/releases/download/v1.7.3/libconfig-1.7.3.tar.gz
tar xvf libconfig-1.7.3.tar.gz
cd libconfig-1.7.3/
./configure --prefix=$PREFIX_CXI 2>&1 | tee configure.log
make -j install 2>&1 | tee make.log

# Libuv https://github.com/libuv/libuv

cd $ROOT_DIR
mkdir -p $LIBCXI_DIR
cd $LIBCXI_DIR
wget https://github.com/libuv/libuv/archive/refs/tags/v1.52.0.tar.gz -O libuv-1.52.0.tar.gz
tar xvf libuv-1.52.0.tar.gz
cd libuv-1.52.0/
./autogen.sh
./configure --prefix=$PREFIX_CXI 2>&1 | tee configure.log
make -j install 2>&1 | tee make.log

# lm-sensors https://github.com/lm-sensors/lm-sensors

cd $ROOT_DIR
mkdir -p $LIBCXI_DIR
cd $LIBCXI_DIR
wget https://github.com/lm-sensors/lm-sensors/archive/refs/tags/V3-6-0.tar.gz -O lm-sensors-3-6-0.tar.gz
tar xvf lm-sensors-3-6-0.tar.gz
cd lm-sensors-3-6-0/
make CC=$CC 2>&1 | tee make.log
make CC=$CC PREFIX=$PREFIX_CXI install 2>&1 | tee make_install.log

### Install LibCXI ###

SHS_VERSION=12.0.2

cd $ROOT_DIR

# shs-cxi-driver https://github.com/HewlettPackard/shs-cxi-driver

mkdir -p $LIBCXI_DIR
cd $LIBCXI_DIR
wget https://github.com/HewlettPackard/shs-cxi-driver/archive/refs/tags/release/shs-${SHS_VERSION}.tar.gz -O shs-cxi-driver-${SHS_VERSION}.tar.gz
tar xvf shs-cxi-driver-${SHS_VERSION}.tar.gz
mkdir -p $PREFIX_CXI/include
cp -r shs-cxi-driver-release-shs-${SHS_VERSION}/include/uapi $PREFIX_CXI/include

# shs-cassini-headers https://github.com/HewlettPackard/shs-cassini-headers
# shs-libcxi/utils/cxi_dump_csrs.py search for ../cassini-headers/install/share/cassini-headers/csr_defs.json

mkdir -p $LIBCXI_DIR
cd $LIBCXI_DIR
wget https://github.com/HewlettPackard/shs-cassini-headers/archive/refs/tags/release/shs-${SHS_VERSION}.tar.gz -O shs-cassini-headers-${SHS_VERSION}.tar.gz
tar xvf shs-cassini-headers-${SHS_VERSION}.tar.gz
mkdir -p cassini-headers
cd cassini-headers
ln -s ../shs-cassini-headers-release-shs-${SHS_VERSION} install # solve hard-coded path
cp -r install/include $PREFIX_CXI/

# LibCXI https://github.com/HewlettPackard/shs-libcxi

cd $ROOT_DIR
mkdir -p $LIBCXI_DIR
cd $LIBCXI_DIR
wget https://github.com/HewlettPackard/shs-libcxi/archive/refs/tags/release/shs-${SHS_VERSION}.tar.gz -O shs-libcxi-${SHS_VERSION}.tar.gz
tar xvf shs-libcxi-${SHS_VERSION}.tar.gz
cd shs-libcxi-release-shs-${SHS_VERSION}
./autogen.sh 2>&1 | tee autogen.log
CPPFLAGS="$CPPFLAGS -D __HIP_PLATFORM_HCC__ -D __HIP_PLATFORM_AMD__" ./configure --prefix=$PREFIX_CXI --with-systemdsystemunitdir=$PREFIX_CXI/lib/systemd --with-udevrulesdir=$PREFIX_CXI/lib/udev 2>&1 | tee configure.log
make install 2>&1 | tee make.log

### Libfabric dependecies ###

# json-c https://github.com/json-c/json-c

cd $ROOT_DIR
mkdir -p $LIBFABRIC_DIR
cd $LIBFABRIC_DIR
wget https://github.com/json-c/json-c/archive/refs/tags/json-c-0.18-20240915.tar.gz
tar xvf json-c-0.18-20240915.tar.gz
cd json-c-json-c-0.18-20240915
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX_LIBFABRIC -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Release .. 2>&1 | tee cmake.log
make install 2>&1 | tee make.log


### Install Libfabric ###

# Libfabric https://github.com/ofiwg/libfabric

cd $ROOT_DIR
mkdir -p $LIBFABRIC_DIR
cd $LIBFABRIC_DIR
VER=2.3.1
wget https://github.com/ofiwg/libfabric/releases/download/v${VER}/libfabric-${VER}.tar.bz2
tar xvf libfabric-${VER}.tar.bz2
cd libfabric-${VER}
./configure --enable-shm --enable-lnx --prefix=$PREFIX_LIBFABRIC --enable-cxi=$PREFIX_CXI ${GPU_LIBFABRIC} \
	    --with-json-c=$PREFIX_LIBFABRIC \
            --disable-sockets --disable-udp --disable-verbs --disable-rxm \
            --disable-mrail --disable-rxd --disable-tcp --disable-usnic \
            --disable-efa --disable-psm2 --disable-psm3 --disable-opx \
            ${XPMEM_LIBFABRIC} 2>&1 | tee configure.log
make -j 10 install 2>&1 | tee make.log

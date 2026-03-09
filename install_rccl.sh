#!/bin/bash -x

# Based on https://github.com/HewlettPackard/shs-ccl-docs/blob/main/rccl/build_rccl_environment.sh

set -e

# We build RCCL twice:
# 1. with the system libfabric (requires to set USE_CPE==1)
# 2. with the custom installed libfabric (USE_CPE!=1)

##### env and modules ###
if [ -z "$GPU_ACCL" ]; then
	export GPU_ACCL=rccl
fi

for USE_CPE in 0 1; do
#for USE_CPE in 1; do
    (
	source sourceme_rccl.sh

	### Delete previous installation
	rm -rf $RCCL_DIR
	rm -rf $PREFIX_RCCL

	PREFIX_HWLOC=$(pkg-config --variable=prefix hwloc)

	cd $ROOT_DIR
	mkdir -p $RCCL_DIR
	mkdir -p $PREFIX_RCCL

	### Install HWLOC only for CPE case, otherwise take OpenMPI installed version
	if [ "${USE_CPE}" == "0" ]; then
	    PREFIX_HWLOC=$(pkg-config --variable=prefix hwloc)
	else
	    cd $RCCL_DIR
	    git clone https://github.com/open-mpi/hwloc.git
	    cd hwloc
	    git checkout "hwloc-2.13.0"
	    ./autogen.sh
	    CC=gcc CXX=g++ ./configure --prefix="$PREFIX_RCCL" 2>&1 | tee configure.log
	    make -j 10 install 2>&1 | tee make.log
	    PREFIX_HWLOC="$PREFIX_RCCL"
	fi

	### Install aws-ofi-nccl
	cd $RCCL_DIR
	git clone https://github.com/aws/aws-ofi-nccl.git
	cd aws-ofi-nccl
	git checkout "v1.18.0"
	./autogen.sh
	CC=gcc CXX=g++ ./configure --prefix="$PREFIX_RCCL" --with-libfabric="$PREFIX_LIBFABRIC" --with-hwloc="$PREFIX_HWLOC" --with-rocm="$ROCM_PATH"  2>&1 | tee configure.log
	make -j 10 install 2>&1 | tee make.log

	### Install RCCL
	cd $RCCL_DIR
	git clone --recursive https://github.com/ROCm/rccl.git
	cd rccl
	git checkout "rocm-6.4.4"
	CXX=hipcc srun -N 1 -n1 -c 16 -A project_462000031 -p dev-g --exclusive --gres=gpu:8 -t 30:00 ./install.sh -j 10 --prefix="$PREFIX_RCCL" --disable-msccl-kernel --fast 2>&1 | tee install.log

	### Install tests
	cd $RCCL_DIR
	git clone https://github.com/ROCm/rccl-tests.git
	cd rccl-tests
	if [ "${USE_CPE}" == "0" ]; then
	    MPI_HOME="${PREFIX_OMPI}"
	else
	    MPI_HOME="${CRAY_MPICH_PREFIX}"
	fi
	CXX=hipcc ./install.sh --rocm_home=$ROCM_PATH --rccl_home=$PREFIX_RCCL --mpi --mpi_home="${MPI_HOME}" --hip_compiler=$(which hipcc) --gpu_targets=gfx90a
	# Install binaries
	cd build
	mkdir -p $PREFIX_RCCL/bin
	cp *_perf $PREFIX_RCCL/bin
)
done

# Generate module files
echo "Generating RCCL module files..."
$ROOT_DIR/generate_modulefiles.sh rccl

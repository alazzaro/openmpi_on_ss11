case "$USER" in
    lazzaroa)
	module load PrgEnv-gnu
	module load rocm
	module list

	echo "ROCM_PATH = "$ROCM_PATH

	XPMEM_ROOT=$(pkg-config --variable=libdir cray-xpmem)
	XPMEM_LIBFABRIC="--enable-xpmem=${XPMEM_ROOT}"
	echo "XPMEM Lib path  = "$XPMEM_ROOT

	GPU_INCLUDE="-I$ROCM_PATH/include"
	GPU_LIBFABRIC="--with-rocr=$ROCM_PATH"
	;;
    marcink)
	if [ "${CRAY_MPICH_VER}" -eq "" ]; then
	    ml load NRIS/GPU
	    ml load libfabric/2.3.1-GCCcore-14.3.0
	fi
	return 0
	;;
    *)
        export CUSTOM_INSTALL=1
	echo "User not recongnized"
	exit -1
	;;
esac

export ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd -P )
echo "ROOT_DIR = "$ROOT_DIR
export PREFIX_CXI=$ROOT_DIR/install_cxi # installation directory
export PREFIX_LIBFABRIC=$ROOT_DIR/install_libfabric # installation directory
export LIBFABRIC_DIR=$ROOT_DIR/libfabric
export LIBCXI_DIR=$LIBFABRIC_DIR/libcxi

export c=gnu
export CC=gcc-14
export CFLAGS="-g -O -Wno-error=maybe-uninitialized -I$PREFIX_CXI/include $GPU_INCLUDE"
export CPPFLAGS="-I$PREFIX_CXI/include $GPU_INCLUDE"

export CXX=g++-14
export CXXFLAGS="-g -O -I$PREFIX_CXI/include $GPU_INCLUDE"

export FC=gfortran-14
export FCFLAGS="-O -I$PREFIX_CXI/include $GPU_INCLUDE"

export LDFLAGS="-g -O -L$PREFIX_CXI/lib"

export PATH=${PREFIX_CXI}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_CXI}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_CXI/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_CXI/man:$MANPATH

export PATH=${PREFIX_LIBFABRIC}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_LIBFABRIC}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_LIBFABRIC/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_LIBFABRIC/man:$MANPATH

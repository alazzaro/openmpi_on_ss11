
function change_dir() {
    local SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    cd $SCRIPT_DIR
}

case "$USER" in
    lazzaroa)
        XPMEM_OMPI="--with-cray-xpmem=yes --with-xpmem=${XPMEM_ROOT}"
        GPU_OMPI="--with-rocm=$ROCM_PATH"
        ;;
    *)
        echo "User not recongnized"
        exit -1
        ;;
esac

OLDDIR=`pwd`
change_dir

source sourceme_libfabric.sh

export PREFIX_OMPI=$ROOT_DIR/install_ompi # installation directory
export OMPI_DIR=$ROOT_DIR/openmpi5

export PATH=${PREFIX_OMPI}/bin:${PATH}
export LD_LIBRARY_PATH=${PREFIX_OMPI}/lib:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=$PREFIX_OMPI/lib/pkgconfig:$PKG_CONFIG_PATH
export MANPATH=$PREFIX_OMPI/man:$MANPATH

cd $OLDDIR

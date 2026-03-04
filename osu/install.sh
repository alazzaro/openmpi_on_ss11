
VERSION=7.5.2
rm -rf osu-micro-benchmarks-$VERSION.tar.gz osu-micro-benchmarks-$VERSION
wget https://mvapich.cse.ohio-state.edu/download/mvapich/osu-micro-benchmarks-$VERSION.tar.gz
tar xf osu-micro-benchmarks-$VERSION.tar.gz
cd osu-micro-benchmarks-$VERSION

(
    source ../../sourceme_ompi.sh
    rm -rf $OSU_INSTALL
    ./configure --prefix=$OSU_INSTALL CC=mpicc CXX=mpicxx CFLAGS=-O3 CXXFLAGS=-O3 ${OSU_COMPILE_FLAGS}
    make -j 10 install
)

(
    source ../../sourceme_craympi.sh
    rm -rf $OSU_INSTALL
    make distclean
    ./configure --prefix=$OSU_INSTALL CC=cc CXX=CC CFLAGS=-O3 CXXFLAGS=-O3 ${OSU_COMPILE_FLAGS}
    make -j 10 install
)

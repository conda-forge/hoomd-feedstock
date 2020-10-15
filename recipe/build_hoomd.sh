mkdir -p build-conda
cd build-conda
rm -rf ./*

export CPATH=${PREFIX}/include
export TBB_LINK=${PREFIX}/lib

if [ "$(uname)" == "Darwin" ]; then
    # prevent cmake from using the conda package clangdev for building
    export CC=/usr/bin/gcc
    export CXX=/usr/bin/g++
    export LINUX_ADDITIONAL=""
else
    export LINUX_ADDITIONAL='-DDL_LIB= -DUTIL_LIB='
fi

CUDA_SUPPORT="off"
CUDA_CMAKE_OPTIONS=""
if [[ $1 == "gpu" ]]; then
    CUDA_SUPPORT="on"
    CUDA_CMAKE_OPTIONS=""
    # remove -std=c++17 from CXXFLAGS for compatibility with nvcc
    export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"
fi

cmake ../ \
      -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
      -DPYTHON_EXECUTABLE=${PYTHON} \
      -DENABLE_MPI=off \
      -DENABLE_GPU=${CUDA_SUPPORT} ${CUDA_CMAKE_OPTIONS} \
      -DBUILD_TESTING=on \
      -DENABLE_TBB=on \
      -DBUILD_JIT=off \
      ${LINUX_ADDITIONAL} \
      -GNinja

# compile
ninja -j${CPU_COUNT}

# install
ninja install

mkdir -p build-conda
cd build-conda
rm -rf ./*

if [ "$(uname)" == "Darwin" ]; then
    # temporary hack. Remove when upstream supports the new pybind11 mode: https://pybind11.readthedocs.io/en/stable/cmake/index.html#new-findpython-mode
   export ADDITIONAL_OPTIONS="-DPYBIND11_FINDPYTHON=ON"
else
    export ADDITIONAL_OPTIONS='-DDL_LIB= -DUTIL_LIB='
fi

CUDA_SUPPORT="off"
CUDA_CMAKE_OPTIONS=""
if [[ $1 == "gpu" ]]; then
    CUDA_SUPPORT="on"
    CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"
    # remove -std=c++17 from CXXFLAGS for compatibility with nvcc
    export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"
fi

echo CMake Args: ${CMAKE_ARGS}

cmake ../ \
      ${CMAKE_ARGS} \
      -Dlibgetar_DIR=../hoomd/extern/libgetar \
      -DCMAKE_INSTALL_PREFIX=${SP_DIR} \
      -DPYTHON_EXECUTABLE=${PYTHON} \
      -DENABLE_MPI=off \
      -DENABLE_GPU=${CUDA_SUPPORT} ${CUDA_CMAKE_OPTIONS} \
      -DBUILD_TESTING=off \
      -DENABLE_TBB=on \
      -DBUILD_JIT=off \
      ${ADDITIONAL_OPTIONS} \
      -GNinja

# compile
ninja -j${CPU_COUNT}

# install
ninja install

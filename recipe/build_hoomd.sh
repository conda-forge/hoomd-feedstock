mkdir -p build-conda
cd build-conda
rm -rf ./*

CUDA_SUPPORT="off"
CUDA_CMAKE_OPTIONS=""
if [[ $1 == "gpu" ]]; then
    CUDA_SUPPORT="on"
    # Debugging missing CUDA 12 compiler.
    echo "Library directory contents:"
    ls ${BUILD_PREFIX}/lib
    
    CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_HOST_COMPILER=${CXX}"
    
    CUDA_CMAKE_OPTIONS="${CUDA_CMAKE_OPTIONS} -DCUDA_cuda_LIBRARY=${BUILD_PREFIX}/targets/x86_64-linux/lib/stubs/libcuda.so"
    
    # Optional libraries/tools that cause errors when not found (will fix in a future HOOMD-blue release)
    CUDA_CMAKE_OPTIONS="${CUDA_CMAKE_OPTIONS} -DCUDA_nvToolsExt_LIBRARY=${BUILD_PREFIX}/bin/conda"
    CUDA_CMAKE_OPTIONS="${CUDA_CMAKE_OPTIONS} -DCUDA_MEMCHECK_EXECUTABLE=${BUILD_PREFIX}/bin/conda"
    
    # remove -std=c++17 from CXXFLAGS for compatibility with nvcc
    export CXXFLAGS="$(echo $CXXFLAGS | sed -e 's/ -std=[^ ]*//')"
fi

# work around 'operator delete' is unavailable on macOS: https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake ../ \
      ${CMAKE_ARGS} \
      -DENABLE_MPI=off \
      -DENABLE_GPU=${CUDA_SUPPORT} ${CUDA_CMAKE_OPTIONS} \
      -DBUILD_TESTING=off \
      -DENABLE_TBB=on \
      -DENABLE_LLVM=on \
      -DPLUGINS="" \
      -GNinja

# compile
ninja

# install
ninja install

mkdir -p build-conda
cd build-conda
rm -rf ./*

env

CUDA_SUPPORT="off"
CUDA_CMAKE_OPTIONS=""
if [[ $1 == "gpu" ]]; then
    CUDA_SUPPORT="on"

    if [[ "${cuda_compiler_version}" = 11* ]]; then
        CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_COMPILER=${CUDA_HOME}/bin/nvcc -DCMAKE_CUDA_HOST_COMPILER=${CXX}"
    else
        CUDA_CMAKE_OPTIONS="-DCMAKE_CUDA_HOST_COMPILER=${CXX}"

        [[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
        [[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
        [[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

        # The conda-forge build system does not provide libcuda from an NVIDIA
        # driver, so we link to the stub.
        CUDA_CMAKE_OPTIONS="${CUDA_CMAKE_OPTIONS} -DCUDA_cuda_LIBRARY=${PREFIX}/${targetsDir}/lib/stubs/libcuda.so"
    fi

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

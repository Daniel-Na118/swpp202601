#!/bin/bash

# Edit `LLVM_DIR` to match your system configuration
LLVM_DIR=~/opt/llvm-22.1.0

CLANG=$LLVM_DIR/bin/clang
CLANGXX=$LLVM_DIR/bin/clang++
if [ "$(uname)" == "Darwin" ]; then
    LLD=$LLVM_DIR/bin/ld64.lld
else
    LLD=$LLVM_DIR/bin/ld.lld
fi

cmake -G Ninja -B build \
    -DLLVM_ROOT=$LLVM_DIR \
    -DCMAKE_C_COMPILER=$CLANG \
    -DCMAKE_CXX_COMPILER=$CLANGXX \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=$LLD -stdlib=libc++" \
    -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=$LLD -stdlib=libc++" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    -DBUILD_SHARED_LIBS=ON

cmake --build build

ctest --test-dir build --output-on-failure -V
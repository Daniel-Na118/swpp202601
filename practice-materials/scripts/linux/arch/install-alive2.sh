#!/bin/bash

# Specify LLVM installation directory
LLVM_DIR=~/opt/llvm-22.1.0
# Specify Z3 installation directory (Z3 will be installed here!)
Z3_DIR=~/opt/z3-4.16.0

export PATH="$LLVM_DIR/bin:$PATH"

MACHINE_ARCH=$(uname -m)
LIBCXX_LIBRARY_PATH=$LLVM_DIR/lib/$MACHINE_ARCH-unknown-linux-gnu
if [[ ! -d "$LIBCXX_LIBRARY_PATH" ]]; then
    LIBCXX_LIBRARY_PATH=$LLVM_DIR/lib
fi

echo "[SCRIPT] Installing Arch Linux dependencies... [requires sudo]"
sudo pacman -Syu --noconfirm --needed re2c

# Install Z3
git clone -b z3-4.16.0 https://github.com/Z3Prover/z3.git --depth=1
cd z3
cmake -GNinja -Bbuild \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld -Wl,-rpath,${LIBCXX_LIBRARY_PATH}" \
    -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld -Wl,-rpath,${LIBCXX_LIBRARY_PATH}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$Z3_DIR
cmake --build build && cmake --install build
cd ../

# Download Alive2 source
git clone https://github.com/AliveToolkit/alive2.git
cd alive2

# Build Alive2
git checkout 0dc2be5f04ccb61caebb909a610968cb2348f196
cmake -GNinja -Bbuild \
    -DBUILD_TV=ON \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++ \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld -Wl,-rpath,${LIBCXX_LIBRARY_PATH}" \
    -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld -Wl,-rpath,${LIBCXX_LIBRARY_PATH}" \
    -DCMAKE_PREFIX_PATH="$LLVM_DIR;$Z3_DIR" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
    -DBUILD_SHARED_LIBS=ON
cmake --build build
cd ../

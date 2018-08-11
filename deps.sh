#!/bin/bash -eu

sudo apt-get update
sudo apt-get install python-pip build-essential git cmake python-dev libglib2.0-dev -y

build=~+/build
mkdir -p build

echo "[*] Building Keystone"
cd "$build"
git clone https://github.com/keystone-engine/keystone.git
cd keystone && mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DLLVM_TARGETS_TO_BUILD="X86;ARM;Mips" -G "Unix Makefiles" .. && make -j$(nproc)
echo

echo "[*] Building Capstone"
cd "$build"
git clone https://github.com/aquynh/capstone.git
cd capstone && make -j$(nproc)
echo

echo "[*] Building Unicorn"
cd "$build"
git clone https://github.com/unicorn-engine/unicorn.git
cd unicorn && ./make.sh

echo
echo "[*] Installing projects and Python bindings"
cd "$build/keystone/build" && sudo make install
cd "$build/keystone/bindings/python" && sudo make install

cd "$build/capstone" && sudo make install
cd "$build/capstone/bindings/python" && sudo make install

cd "$build/unicorn" && sudo ./make.sh install
cd "$build/unicorn/bindings/python" && sudo make install

which ldconfig &>/dev/null && sudo ldconfig

echo
echo -n "Testing Python import: "
python -c "import capstone, keystone, unicorn; capstone.CS_ARCH_X86, unicorn.UC_ARCH_X86, keystone.KS_ARCH_X86; print 'works.'"

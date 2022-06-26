#! /bin/sh
rm -rf out
rm -rf build
mkdir -p build || exit

BUILD_TYPE="Debug"
GENERATOR="Ninja Multi-Config"
DEVELOPER_MODE=False
COVERAGE=False
TESTING=True

cd ./build || exit
conan install ../conanfile.py -b missing -pr:b default -s build_type="${BUILD_TYPE}" -s compiler.version=13.1 -g CMakeToolchain
cd ..
cmake -S . -B ./build -G "${GENERATOR}" \
    -DCMAKE_BUILD_TYPE:STRING=${BUILD_TYPE} \
    -DCMAKE_INSTALL_PREFIX:PATH="./usr" \
    -DENABLE_DEVELOPER_MODE:BOOL=${DEVELOPER_MODE} \
    -DOPT_ENABLE_COVERAGE:BOOL=${COVERAGE} \
    -DENABLE_TESTING:BOOL=${TESTING} \
    -DCMAKE_TOOLCHAIN_FILE:PATH="./build/generators/conan_toolchain.cmake"
cmake --build ./build --config ${BUILD_TYPE} --target install
cd build || exit
ctest -VV -C "${BUILD_TYPE}"
cpack -C ${BUILD_TYPE} -G TBZ2
cpack -C ${BUILD_TYPE} -G DragNDrop
# cpack -C ${BUILD_TYPE} -G IFW
cd ..

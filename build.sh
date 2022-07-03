#! /bin/sh
rm -rf out
rm -rf build
mkdir -p build || exit

BUILD_TYPE="Debug"
# GENERATOR="Ninja Multi-Config"
GENERATOR="Ninja"
SHARED_LIBS=True
SELF_CONTAINED=True
TESTING=True
DOCS=False
EXAMPLES=False
COVERAGE=True

cd ./build || exit
conan install ../conanfile.py -b missing -pr:b default -s build_type="${BUILD_TYPE}" -s compiler.version=13.1 -g CMakeToolchain
cd ..
cmake -S . -B ./build -G "${GENERATOR}" \
    -DCMAKE_BUILD_TYPE:STRING=${BUILD_TYPE} \
    -DCMAKE_INSTALL_PREFIX:PATH="./Application" \
    -DBUILD_SHARED_LIBS:BOOL=${SHARED_LIBS} \
    -DOPTION_SELF_CONTAINED:BOOL=${SELF_CONTAINED} \
    -DOPTION_BUILD_TESTS:BOOL=${TESTING} \
    -DOPTION_BUILD_DOCS:BOOL=${DOCS} \
    -DOPTION_BUILD_EXAMPLES:BOOL=${EXAMPLES} \
    -DOPTION_ENABLE_COVERAGE:BOOL=${COVERAGE} \
    -DCMAKE_TOOLCHAIN_FILE:PATH="./build/generators/conan_toolchain.cmake"

cmake --build ./build --config ${BUILD_TYPE} --target install
cd build || exit
ctest -VV -C "${BUILD_TYPE}"
cpack -C ${BUILD_TYPE} -G TBZ2
cpack -C ${BUILD_TYPE} -G DragNDrop
# cpack -C ${BUILD_TYPE} -G IFW
cd ..

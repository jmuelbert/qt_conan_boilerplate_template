#! /bin/sh

# Style

rm -rf out
rm -rf build
mkdir -p build || exit
mkdir -p install || exit

BUILD_TYPE="Debug"
GENERATOR="Ninja Multi-Config"
# WITH_IPO="ON"
# NATIVE_OPTIMIZATION="ON"
# CACHE="ON"
# COVERAGE="ON"
# DOXYGEN="ON"
# CPPCHECK="ON"
# CLANG_TIDY="ON"
# VS_ANALYSIS="OFF"
# INCLUDE_WHAT_YOU_USE="ON"
# PCH="ON"
# TESTING=ON
APPIMAGE_DST_PATH="${TARGET_NAME}.AppDir"
TARGET_NAME=qtwidgettest

cd ./build || exit
# conan install ../conanfile.py -pr:b=default -pr:h=default -b missing -s build_type="${BUILD_TYPE}" -o QtTestConan:build_all=True
# conan create ../conanfile.py -pr:b=default -pr:h=default -o QtTestConan:build_docs=True -o QtTestConan:build_tests=True -o QtTestConan:build_all=True
cd ..
cmake -S . -B build -G "$GENERATOR" \
  -DCMAKE_BUILD_TYPE:STRING="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${APPIMAGE_DST_PATH}/usr" \
  -DBUILD_SHARED_LIBS:BOOL="${SHARED_LIBS}" \
  -DOPTION_BUILD_TESTS:BOOL="${TESTING}" \
  -DBUILD_ALL:BOOL="ON" \
  -DENABLE_CONAN:BOOL="ON" \
  -DOPTION_BUILD_DOCS:BOOL="${DOCS}" \
  -DOPTION_ENABLE_COVERAGE:BOOL="${COVERAGE}"
# -DCMAKE_TOOLCHAIN_FILE:PATH="generators/conan_toolchain.cmake"

cmake --build ./build --config "${BUILD_TYPE}" --target install
cmake --build ./build --config "${BUILD_TYPE}" --target pack

ctest -VV -C "${BUILD_TYPE}"

# cpack -C ${BUILD_TYPE} -G TBZ2
# cpack -C ${BUILD_TYPE} -G DragNDrop
# cpack -C ${BUILD_TYPE} -G IFW

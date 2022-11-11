#! /bin/sh

# Style
osType="$(uname -s)"

case "$osType" in
"Darwin")
  {
    echo "Running on Mac OSX."
    CURRENT_OS="OSX"
    BUILD_DIR=build
  }
  ;;
"Linux")
  {
    BUILD_DIR=build
  }
  ;;
*)
  {
    echo "Unsupported OS, exiting"
    exit
  }
  ;;
esac

rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}" || exit

BUILD_TYPE="Debug"
GENERATOR="Ninja"
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
cd ./"${BUILD_DIR}" || exit
conan install ../conanfile.py -pr:b=default -pr:h=default -b missing -s build_type="${BUILD_TYPE}" -s compiler.cppstd=17 -o QtTestConan:build_all=True
# conan create ../conanfile.py -pr:b=default -pr:h=default -o QtTestConan:build_docs=True -o QtTestConan:build_tests=True -o QtTestConan:build_all=True
cd ..
cmake -S . -B "${BUILD_DIR}" -G "$GENERATOR" \
  -DCMAKE_BUILD_TYPE:STRING="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${APPIMAGE_DST_PATH}/usr" \
  -DBUILD_SHARED_LIBS:BOOL="${SHARED_LIBS}" \
  -DOPTION_BUILD_TESTS:BOOL="${TESTING}" \
  -DBUILD_ALL:BOOL="ON" \
  -DENABLE_CONAN:BOOL="ON" \
  -DOPTION_BUILD_DOCS:BOOL="${DOCS}" \
  -DOPTION_ENABLE_COVERAGE:BOOL="${COVERAGE}" \
  -DCMAKE_TOOLCHAIN_FILE:PATH="${BUILD_DIR}/generators/conan_toolchain.cmake"

cmake --build ./"${BUILD_DIR}" --config "${BUILD_TYPE}" --target install
cmake --build ./"${BUILD_DIR}" --config "${BUILD_TYPE}" --target pack

ctest -VV -C "${BUILD_TYPE}"

# cpack -C ${BUILD_TYPE} -G TBZ2
# cpack -C ${BUILD_TYPE} -G DragNDrop
# cpack -C ${BUILD_TYPE} -G IFW

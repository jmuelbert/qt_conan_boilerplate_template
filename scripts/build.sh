#! /bin/bash

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

# Function to test exit status of a command.
# It exits if the command failed.
function testExitStatus() {
  if [ $1 -ne 0 ]; then
    echo "$2 failed"
    exit 1
  else
    echo "$2 successed"
  fi
}

# Create build directory
BUILD_DIR=build
mkdir -pv "${BUILD_DIR}" || exit
testExitStatus $? "mkdir"

# Update path into build directory
cd build
testExitStatus $? "cd"
conan user
conan profile new default --detect --force

# Configure cmake
cmake -S .. -B . -G "$GENERATOR" \
  -DCMAKE_BUILD_TYPE:STRING="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${APPIMAGE_DST_PATH}/usr" \
  -DBUILD_SHARED_LIBS:BOOL="${SHARED_LIBS}" \
  -DOPTION_BUILD_TESTS:BOOL="${TESTING}" \
  -DOPTION_BUILD_DOCS:BOOL="${DOCS}" \
  -DOPTION_ENABLE_COVERAGE:BOOL="${COVERAGE}"

testExitStatus $? "cmake config"

# Build using cmake (with install)
cmake --build . --config "${BUILD_TYPE}" --target install
testExitStatus $? "cmake build"

# Package
cmake --build . --config "${BUILD_TYPE}" --target all

# Test with CTest
ctest -VV -C "${BUILD_TYPE}"

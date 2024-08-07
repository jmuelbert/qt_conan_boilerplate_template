#! /bin/bash

CMAKE_EXPORT_COMPILE_COMMANDS="ON"
BUILD_TYPE="RelWithDebInfo"
GENERATOR="Ninja"
# WITH_IPO="ON"
# NATIVE_OPTIMIZATION="ON"
CACHE="ON"
# COVERAGE="ON"
# DOXYGEN="ON"
CPPCHECK="ON"
CLANG_TIDY="ON"
INCLUDE_WHAT_YOU_USE="ON"
# PCH="ON"
TESTING="OFF"
TARGET_NAME=qtwidgettest
APPIMAGE_DST_PATH="${TARGET_NAME}.AppDir"


# Function to test exit status of a command.
# It exits if the command failed.
function testExitStatus() {
  if [ "$1" -ne 0 ]; then
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
cd build || exit

conan user
conan profile new default --detect --force

# Configure cmake
cmake -S .. -B . -G "$GENERATOR" \
  -DCMAKE_BUILD_TYPE:STRING="${BUILD_TYPE}" \
  -DCMAKE_INSTALL_PREFIX:PATH="${APPIMAGE_DST_PATH}/usr" \
  -DBUILD_SHARED_LIBS:BOOL="${SHARED_LIBS}" \
  -DBUILD_TESTING:BOOL="${TESTING}" \
  -DENABLE_CACHE="${CACHE}" \
  -DENABLE_INCLUDE_WHAT_YOU_USE="${INCLUDE_WHAT_YOU_USE}" \
  -DENABLE_CLANG_TIDY="${CLANG_TIDY}" \
  -DENABLE_CPPCHECK="${CPPCHECK}" \
  -DENABLE_CLAZY="${CLAZY}" \
  -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL="ON"

testExitStatus $? "cmake config"

echo "CMAKE_COMPILER_CXX:  ${CMAKE_COMPILER_CXX}"

# Build using cmake (with install)
echo "Build target install..."
cmake --build . --config "${BUILD_TYPE}"
testExitStatus $? "cmake build"

# Test with CTest
echo "All tests..."
ctest -VV -C "${BUILD_TYPE}"

# CPack
echo "Pack"
cpack -C "${BUILD_TYPE}" -G "DragNDrop;ZIP"

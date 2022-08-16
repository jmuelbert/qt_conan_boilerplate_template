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

APPIMAGE_DST_PATH="./${TARGET_NAME}.AppDir"
TARGET_NAME=qtwidgettest

cd ./build || exit
conan install ../conanfile.py -b missing -pr:b default -s build_type="${BUILD_TYPE}" -g CMakeToolchain
cmake -S .. -B . -G "$GENERATOR" \
    -DCMAKE_BUILD_TYPE:STRING="${BUILD_TYPE}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${APPIMAGE_DST_PATH}/usr" \
    -DBUILD_SHARED_LIBS:BOOL="${SHARED_LIBS}" \
    -DOPTION_SELF_CONTAINED:BOOL="${SELF_CONTAINED}" \
    -DOPTION_BUILD_TESTS:BOOL="${TESTING}" \
    -DOPTION_BUILD_DOCS:BOOL="${DOCS}" \
    -DOPTION_BUILD_EXAMPLES:BOOL="${EXAMPLES}" \
    -DOPTION_ENABLE_COVERAGE:BOOL="${COVERAGE}" \
    -DCMAKE_TOOLCHAIN_FILE:PATH="./build/generators/conan_toolchain.cmake"

cmake --build . --config "${BUILD_TYPE}" --target install
cmake --build . --config "${BUILD_TYPE}" --target pack
ctest -VV -C "${BUILD_TYPE}"

prettier --check .
find . -type f -name 'CMakeLists.txt' -exec cmake-format {} \;
find . -type f -name 'CMakeLists.txt' -exec cmake-lint {} \;
find -E . -regex 'src/.*\.(cpp|hpp|cc|cxx)' -exec clang-format -style=file -i {} \;
find -E . -regex 'test/.*\.(cpp|hpp|cc|cxx)' -exec clang-format -style=file -i {} \;
find -E . -regex 'src/.*\.(cpp|hpp|cc|cxx)' -exec clang-tidy -format-style=file --fix {} \;
find -E . -regex 'test/.*\.(cpp|hpp|cc|cxx)' -exec clang-tidy -format-style=file --fix {} \;
find -E . -regex 'src/.*\.(cpp|hpp|cc|cxx)' -exec cpplint {} \;
find -E . -regex 'test/.*\.(cpp|hpp|cc|cxx)' -exec cpplint {} \;
find -E . -regex 'src/.*\.(cpp|hpp|cc|cxx)' -exec cppcheck {} \;
find -E . -regex 'test/.*\.(cpp|hpp|cc|cxx)' -exec cppcheck {} \;
# cpack -C ${BUILD_TYPE} -G TBZ2
# cpack -C ${BUILD_TYPE} -G DragNDrop
# cpack -C ${BUILD_TYPE} -G IFW
cd ..

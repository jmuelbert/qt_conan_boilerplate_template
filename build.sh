#! /bin/sh

rm -rf build
rm -rf cmake-build*
mkdir -p build
cd build || exit
conan install .. -b missing -pr:b default -s build_type=Debug
cd ..
cmake --preset Debug
cmake --build --preset Debug

conan install ./conanfile.py -s build_type=Debug -s compiler=apple-clang -s compiler.version=13.1 -s compiler.libcxx=libc++ -e=CONAN_CMAKE_TOOLCHAIN_FILE="./conan-dependencies/toolchain.cmake" -g=cmake_paths -g=json -g=cmake --build=missing -if=/Users/juergen/Projects/GitHub/build-qt_conan_boilerplate_template-Desktop_Qt_clang_64bit_qt_qt5-Debug/conan-dependencies


cmake_minimum_required(VERSION 3.23)

project(
  conan_test
  VERSION 0.0.1
  LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)

add_subdirectory(lib)
add_subdirectory(app)

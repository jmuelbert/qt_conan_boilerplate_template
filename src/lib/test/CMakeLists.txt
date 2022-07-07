cmake_minimum_required(VERSION 3.15...3.23 FATAL_ERROR)

# Meta information about the project

set(META_PROJECT_NAME "qtconanboilerplate")

# Declare project
project("${META_PROJECT_NAME}-tests" C CXX)

# Set policies
set_policy(CMP0054 NEW) # ENABLE CMP0054: Only interpret if() arguments as variables or keywords when unquoted.
set_policy(CMP0042 NEW) # ENABLE CMP0042: MACOSX_RPATH is enabled by default.
set_policy(CMP0063 NEW) # ENABLE CMP0063: Honor visibility properties for all target types.

# Compiler settings and options

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake")
  include(${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake/CompileOptions.cmake)
  include(${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake/Custom.cmake)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake")
else()
  include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/CompileOptions.cmake)
  include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/Custom.cmake)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
endif()

find_package(
  Qt6
  COMPONENTS Test
  REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

qt_add_executable(
  testMain
  MANUAL_FINALIZATION
  testmain.cpp
  testmain.h)

set_target_properties(testMain PROPERTIES WIN32_EXECUTABLE TRUE)

if(WIN32)
  target_link_options(testMain PRIVATE "/entry:mainCRTStartup")
endif()

target_link_libraries(testMain PRIVATE Qt6::Test ${META_PROJECT_NAME}::myclass)

qt_finalize_executable(testMain)

add_test(NAME testMain COMMAND testMain)

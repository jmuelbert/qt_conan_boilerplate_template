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

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(
  QT
  NAMES
  Qt6
  Qt5
  REQUIRED
  COMPONENTS Core)

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Test)

set(CMAKE_INCLUDE_CURRENT_DIR ON)


if(${QT_VERSION_MAJOR} GREATER_EQUAL 
qt_standard_project_setup()
qt_add_executable(
  testMain
  MANUAL_FINALIZATION
  testmain.cpp
  testmain.h)
else()
  add_executable( testMain
  testmain.cpp
  testmain.h)
endif()

set_target_properties(testMain PROPERTIES WIN32_EXECUTABLE TRUE)

if(WIN32)
  target_link_options(testMain PRIVATE "/entry:mainCRTStartup")
endif()

target_link_libraries(testMain 
  PRIVATE 
  Qt${QT_VERSION_MAJOR}::Core
  Qt${QT_VERSION_MAJOR}::Test 
  ${META_PROJECT_NAME}::myclass)

if(QT_VERSION_MAJOR EQUAL 6)
qt_finalize_executable(testMain)
endif()

add_test(NAME testMain COMMAND testMain)

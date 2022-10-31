#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#
#

# ECM_ENABLE_SANITIZER='address;leak;undefined'
# Default="'address;leak;undefined'"
#
#
# ENABLE=CACHE=[True, False]
# Default="ON"
#
# ENABLE=COVERAGE=[True, False]
# Default="ON"
#
# ENABLE_DOXYGEN=[True, False]
# Default="ON"
#
# ENABLE_CPPCHECK=[True, False]
# Default="ON"
#
# ENABLE_CLANG_TIDY=[True, False]
# Default"ON"
#
# ENABLE_VS_ANALYSIS=[True, False]
# Default="OFF"
#
# INCLUDE_WHAT_YOU_USE=[True, False]
# Default="ON"
#
# ENABLE_PCH=[True, False]
# Default="ON"
#
#
# OPTION_BUILD_TESTS=[True, False]
# Default=OFF

cmake_minimum_required(VERSION 3.20..3.24 FATAL_ERROR)

# Set policies
# Make sure that an old version of CMake is not being used so modern features are available
# Update this to the mix, max versions that are applicable
if(${CMAKE_VERSION} VERSION_LESS 3.24)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
else()
    cmake_policy(VERSION 3.24)
endif()

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

# Declare project
project(
    qtwidgettest}
    VERSION 0.0.2
    DESCRIPTION "A qt cpp conan template project"
    HOMEPAGE_URL "https://gihub.com/jmuelbert/qt_conan_boilerplate_template"
    LANGUAGES C CXX
)

# Project Options
option(ECM_ENABLE_SANITIZER "ECM_ENABLE_SANITIZERS" "address;leak;undefined")
option(ENABLE_NATIVE_OPTIMIZATION "NATIVE_OPTIMIZATION" ON)
option(ENABLE_CACHE "CACHE" ON)
option(ENABLE_CONAN "Load the depend libs with conan" OFF)
option(ENABLE_COVERAGE "COVERAGE" ON)
option(ENABLE_DOXYGEN "DOXYGEN" ON)
option(ENABLE_CPPCHECK "CPPCHECK" ON)
option(ENABLE_CLANG_TIDY "CLANG_TIDY" ON)
option(ENABLE_VS_ANALYSIS "VS_ANALYSIS" OFF)
option(ENABLE_INCLUDE_WHAT_YOU_USE "INCLUDE_WHAT_YOU_USE" ON)
option(ENABLE_PCH "PCH" ON)
option(OPTION_BUILD_TESTS "Build an run tests" OFF)

# Include cmake modules
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

set(projectPrefix QTTESTWIDGET_)

# Options to enable folders in CMake generated projects for Visual Studio, Xcode, etc
# Very useful to put 3rd-party libraries such as Minizip, GoogleTest and FuzzyLite in their own folders
set_property(GLOBAL PROPERTY USE_FOLDERS TRUE)
# Make FOLDER property inheritable
# So when we set FOLDER property on AI directory all and targets inside will inherit it
#
# Important! This trick depend on undefined behavior since we override CMake own property.
# In same time define_property documentation states it's function for custom properties.
define_property(
    TARGET
    PROPERTY FOLDER
    INHERITED
    BRIEF_DOCS
        "Set
       the
       folder
       name."
    FULL_DOCS
        "Use
       to
       organize
       targets
       in
       an
       IDE.
       "
)

include_guard()

# only usable here
set(ProjectOptions_SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/cmake)

# include the files to allow calling individual functions (including the files does not run any code.)
include(Common)
include(Utilities)
include(SystemLink)
include(Cuda)
include(PackageProject)
include(Optimization)
include(Cache)
include(Linker)
include(CompilerWarnings)
include(Tests)
include(Doxygen)
include(StaticAnalyzers)
include(MinGW)
include(DetectCompiler)
include(VCEnvironment)

include(Conan)
include(Vcpkg)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})

# Activate ECM
find_package(ECM REQUIRED NO_MODULE)
list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

common_project_options()

if(ECM_ENABLE_SANITIZER)
    include(ECMEnableSanitizers)
endif()

if(ENABLE_CACHE)
    # enable cache system
    enable_cache()
endif()

# if(ENABLE_COVERAGE)
#     enable_coverage(${PROJECT_NAME})
# endif()

if(ENABLE_DOXYGEN})
    # enable doxygen
    enable_doxygen()
endif()

# allow for static analysis options
if(ENABLE_CPPCHECK)
    enable_cppcheck(CPPCHECK_OPTIONS)
endif()

if(ENABLE_CLANG_TIDY)
    enable_clang_tidy()
endif()

if(ENABLE_VS_ANALYSIS)
    enable_vs_analysis(VS_ANALYSIS_RULESET)
endif()

if(ENABLE_INCLUDE_WHAT_YOU_USE)
    enable_include_what_you_use()
endif()

# if(ENABLE_PCH)
#     if(NOT PCH_HEADERS)
#         set(PCH_HEADERS <vector> <string> <map> <utility>)
#     endif()
#     target_precompile_headers(${_options_target} INTERFACE PCH_HEADERS)
# endif()

if(ENABLE_VCPKG)
    run_vcpkg()
endif()

if(ENABLE_CONAN)
    run_conan()
endif()

#
# Project modules
#

# Add subdirs for headers, sources, and executables
# Subdirs contain CMakeLists.txt files with commands to setup build
# Comment the following line if the library is header-only
add_subdirectory(src)

# add usage example
# add_subdirectory(example)

# generate project documentation
# if(ENABLE_DOXYGEN)
#     run_doxygen()
# endif()

# Tests
if(OPTION_BUILD_TESTS)
    set(IDE_FOLDER "Tests")
    enable_testing()
    add_subdirectory(test)
endif()

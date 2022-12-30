#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
# Author: Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#
#

# Pass the following variables to cmake to control the build process:
#
# BUILD_TESTING=[True, False]
# Default=OFF
#
# ENABLE_CONAN=[True, False]
# Default=True
#
# TODO: Implement!
#
# -DXXX_QT6=[true, false]
# Build against QT6 rather than Qt5
# Default=true (Qt6 will be used by default)

cmake_minimum_required(VERSION 3.16..3.24 FATAL_ERROR)

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
    qtwidgettest
    VERSION 0.0.2
    DESCRIPTION "A qt cpp conan template project"
    HOMEPAGE_URL "https://gihub.com/jmuelbert/qt_conan_boilerplate_template"
    LANGUAGES C CXX
)

include_guard()

set(PROJECT_NAME_CAPITALIZED "QtWidgetTest")

# This can be read from ${PROJECT_NAME} after project() is called
if(APPLE)
    set(CMAKE_OSX_DEPLOYMENT_TARGET
        "10.15"
        CACHE STRING "Minimum OS X deployment version"
    )
endif()

# Project Option
option(BUILD_TESTING "Build and run all tests" OFF)
option(ENABLE_CONAN "Load dependecies with conan" TRUE)

set(projectPrefix ${PROJECT_NAME_CAPILIZED}_)

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
    BRIEF_DOCS "Set the folder name."
    FULL_DOCS "Use to organize targets in an IDE."
)

set(QT_MIN_VERSION "5.15.2")
set(KF5_DEP_VERSION "5.90.0")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Include cmake modules
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
list(
    APPEND
    CMAKE_MODULE_PATH
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/generators
    ${CMAKE_BINARY_DIR}/build/generators
)
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})

# only usable here
set(ProjectOptions_SRC_DIR ${CMAKE_CURRENT_LIST_DIR}/cmake)

# include the files to allow calling individual functions (including the files does not run any code.)
include(cmake/project-is-top-level.cmake)
include(cmake/variables.cmake)
include(Cache)
include(CompilerWarnings)
include(StaticAnalyzers)



if(ENABLE_CONAN)
    include(Conan)
    run_conan()
    include(conan_toolchain)
endif()

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDECompilerSettings NO_POLICY_SCOPE)
include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEClangFormat)
include(KDEGitCommitHooks)

include(ECMOptionalAddSubdirectory)
include(ECMAddAppIcon)
include(ECMInstallIcons)
include(ECMDeprecationSettings)

include(FeatureSummary)

# Forbid some old things
add_definitions(-DQT_NO_FOREACH)

add_library(
    project_options INTERFACE
)
target_compile_features(project_options INTERFACE cxx_std_17)

#
# Project modules
#

# Add subdirs for headers, sources, and executables
# Subdirs contain CMakeLists.txt files with commands to setup build
# Comment the following line if the library is header-only
ecm_optional_add_subdirectory(src)

# our documentation
ecm_optional_add_subdirectory(doc)

# Tests
if(BUILD_TESTING)
    set(IDE_FOLDER "Tests")
    enable_testing()
    add_subdirectory(test)
endif()

feature_summary(INCLUDE_QUIET_PACKAGES WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)

file(
    GLOB_RECURSE
    ALL_CLANG_FORMAT_SOURCE_FILES
    *.cpp
    *.h
    *.hpp
    *.c
)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})
kde_configure_git_pre_commit_hook(CHECKS CLANG_FORMAT)


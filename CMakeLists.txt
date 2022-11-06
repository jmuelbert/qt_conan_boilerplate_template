#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#
#

#
# BUILD_TESTING=[True, False]
# Default=OFF
#

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
option(ENABLE_CONAN "Load the depend libs with conan" OFF)
option(BUILD_TESTING "Build and run all tests" OFF)

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
include(cmake/project-is-top-level.cmake)
include(cmake/variables.cmake)
include(cmake/folders.cmake)
include(PackageProject)
include(CompilerWarnings)
include(StaticAnalyzers)
include(FeatureSummary)

include(Conan)
include(Vcpkg)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}/generators)
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR} ${CMAKE_BINARY_DIR}/generators)

if(ENABLE_VCPKG)
    run_vcpkg()
endif()

if(ENABLE_CONAN)
    run_conan()
    # Call with the CMakeDeps generator
    include(${CMAKE_BINARY_DIR}/generators/cmakedeps_macros.cmake)
endif()

# # Activate ECM
# find_package(ECM REQUIRED NO_MODULE)
# list(APPEND CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

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
if(BUILD_TESTING)
    set(IDE_FOLDER "Tests")
    enable_testing()
    add_subdirectory(test)
endif()

include(cmake/dev-mode.cmake)

feature_summary(WHAT ENABLED_FEATURES DISABLED_FEATURES)

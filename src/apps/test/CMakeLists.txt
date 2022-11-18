#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#

cmake_minimum_required(VERSION 3.16..3.24 FATAL_ERROR)

# Set policies
# Make sure that an old version of CMake is not being used so modern features are available
# Update this to the mix, max versions that are applicable
if(${CMAKE_VERSION} VERSION_LESS 3.24)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
else()
    cmake_policy(VERSION 3.24)
endif()

# Meta information about the project
set(META_PROJECT_NAME "qtwidgettest-app")

# Declare project
project("${META_PROJECT_NAME}-tests" LANGUAGES CXX)

# Compiler settings and options

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

# ---- Dependencies ----

find_package(Catch2 CONFIG REQUIRED)

include(Catch)

if(APPLE)
    set(EXECUTABLE_PATH "qtwidgettest.app/Contents/MacOS/qtwidgettest")
else()
    set(EXECUTABLE_PATH "qtwidgettest")
endif()

add_executable(
    catch_main
    catch_main.cpp
)
target_link_libraries(
    catch_main
    PUBLIC Catch2::Catch2WithMain
)

# Provide a simple smoke test to make sure that the CLI works and can display a --help message
add_test(NAME cli.has_help COMMAND catch_main --help)

# Provide a test to verify that the version being reported from the application
# matches the version given to CMake. This will be important once you package
# your program. Real world shows that this is the kind of simple mistake that is easy
# to make, but also easy to test for.
add_test(NAME cli.version_matches COMMAND ${EXECUTABLE_PATH} --version)
set_tests_properties(cli.version_matches PROPERTIES PASS_REGULAR_EXPRESSION "${PROJECT_VERSION}")

add_folders(apps_test)

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

# Declare project
project(
    qtwidgettest-test1
    VERSION 0.0.2
    LANGUAGES CXX
)

include_guard()

set(PROJECT_PREFIX QTWIDGETTEST_TEST1_)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(GNUInstallDirs)
include(CTest)

#
# Sources
#

# ---- Dependencies ----

find_package(Catch2 CONFIG REQUIRED)

include(Catch)

add_executable(
    tests
    tests.cpp
)

target_link_libraries(
    tests
    PRIVATE Catch2::Catch2WithMain
)

add_test(NAME tests COMMAND tests)

# TODO: Adopt to V3
# automatically discover tests that are defined in catch based test files you can modify the unittests. Set TEST_PREFIX
# to whatever you want, or use different for different binaries
# catch_discover_tests(
#   tests
#   TEST_PREFIX
#   "unittests."
#   REPORTER
#   xml
#   OUTPUT_DIR
#   .
#   OUTPUT_PREFIX
#   "unittests."
#   OUTPUT_SUFFIX
#   .xml)

# TODO: Adopt to V3
# Add a file containing a set of constexpr tests
add_executable(
    constexpr_tests
    constexpr_tests.cpp
)

target_link_libraries(
    constexpr_tests
    PRIVATE Catch2::Catch2WithMain
)

add_test(NAME constexpr_tests COMMAND constexpr_tests)

# catch_discover_tests(
#   constexpr_tests
#   TEST_PREFIX
#   "constexpr."
#   REPORTER
#   xml
#   OUTPUT_DIR
#   .
#   OUTPUT_PREFIX
#   "constexpr."
#   OUTPUT_SUFFIX
#   .xml)

# Disable the constexpr portion of the test, and build again this allows us to have an executable that we can debug when
# things go wrong with the constexpr testing
add_executable(
    relaxed_constexpr_tests
    constexpr_tests.cpp
)

target_link_libraries(
    relaxed_constexpr_tests
    PRIVATE Catch2::Catch2WithMain
)

target_compile_definitions(relaxed_constexpr_tests PRIVATE -DCATCH_CONFIG_RUNTIME_STATIC_REQUIRE)
add_test(NAME relaxed_constexpr_tests COMMAND relaxed_constexpr_tests)

# TODO: Adopt to V3
# catch_discover_tests(
#   relaxed_constexpr_tests
#   TEST_PREFIX
#   "relaxed_constexpr."
#   REPORTER
#   xml
#   OUTPUT_DIR
#   .
#   OUTPUT_PREFIX
#   "relaxed_constexpr."
#   OUTPUT_SUFFIX
#   .xml)

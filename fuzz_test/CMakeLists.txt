#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#
#
# A fuzz test runs until it finds an error. This particular one is going to rely on libFuzzer.

#

cmake_minimum_required(VERSION 3.16..3.24 FATAL_ERROR)

# Set policies
# Makesure thet an old version of CMake is not being used so modern features are available
# Update this to the mix, max versions that are applicable.
if(${CMAKE_VERSION} VERSION_LESS 3.24)
    cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_VERSION_MINOR})
else()
    cmake_policy(VERSION 3.24)
endif()

include_guard()

find_package(fmt)

add_executable(
    fuzz_tester
    fuzz_tester.cpp
)
target_link_libraries(
    fuzz_tester
    PRIVATE project_options
            project_warnings
            fmt::fmt
            -coverage
            -fsanitize=fuzzer,undefined,address
)
target_compile_options(fuzz_tester PRIVATE -fsanitize=fuzzer,undefined,address)

# Allow short runs during automated testing to see if something new breaks
set(FUZZ_RUNTIME
    10
    CACHE STRING "Number of seconds to run fuzz tests during ctest run"
) # Default of 10 seconds

add_test(NAME fuzz_tester_run COMMAND fuzz_tester -max_total_time=${FUZZ_RUNTIME})

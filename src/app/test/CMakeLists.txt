cmake_minimum_required(VERSION 3.15...3.23)

# Meta information about the project
set(META_PROJECT_NAME "qtwidgettest-app")

# Declare project
project("${META_PROJECT_NAME}-tests" C CXX)

# Set policies
set_policy(CMP0054 NEW) # ENABLE CMP0054: Only interpret if() arguments as variables or keywords when unquoted.
set_policy(CMP0042 NEW) # ENABLE CMP0042: MACOSX_RPATH is enabled by default.
set_policy(CMP0063 NEW) # ENABLE CMP0063: Honor visibility properties for all target types.

# Compiler settings and options

if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake")
    include(${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake/CompileOptions.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake/Custom.cmake)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../../../cmake")
else()
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/CompileOptions.cmake)
    include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/Custom.cmake)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
endif()


# ---- Dependencies ----

find_package(Catch2 CONFIG REQUIRED)

include(Catch)

if(APPLE)
set(executable_path "qtwidgettest.app/Contents/MacOS/qtwidgettest")
else()
set(executable_path "qtwidgettest")
endif()

add_library(catch_main OBJECT catch_main.cpp)
target_link_libraries(catch_main PUBLIC Catch2::Catch2)

# Provide a simple smoke test to make sure that the CLI works and can display a --help message
add_test(NAME cli.has_help COMMAND ${executable_path} --help)

# Provide a test to verify that the version being reported from the application
# matches the version given to CMake. This will be important once you package
# your program. Real world shows that this is the kind of simple mistake that is easy
# to make, but also easy to test for.
add_test(NAME cli.version_matches COMMAND ${executable_path} --version)
set_tests_properties(cli.version_matches PROPERTIES PASS_REGULAR_EXPRESSION "${PROJECT_VERSION}")


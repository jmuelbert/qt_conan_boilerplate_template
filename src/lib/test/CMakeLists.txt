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
    qtwidgettestlib-test
    VERSION 0.0.2
    LANGUAGES CXX
)


include_guard()

set(PROJECT_PREFIX QTWIDGETTESTLIB_TEST_)

option(${PROJECT_PREFIX}AS_SYSTEM_HEADERS "Exports library as system HEADERS" OFF)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(CTest)

#
# Sources
#

set(INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}")
set(SOURCE_PATH"${CMAKE_CURRENT_SOURCE_DIR}/source")

set(HEADERS testmain.h)
set(SOURCES testmain.cpp)

find_package(
    QT
    NAMES
    Qt6
    Qt5
    REQUIRED
    COMPONENTS Core
)

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core Test)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    if(${QT_VERSION_MINOR} GREATER_EQUAL 3)
        qt_standard_project_setup()
    else()
        set(CMAKE_AUTOMOC ON)
        set(CMAKE_AUTOUIC ON)
        include(GNUInstallDirs)
    endif()
    qt_add_executable(testMain MANUAL_FINALIZATION testmain.cpp testmain.h)
else()
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTOUIC ON)
    include(GNUInstallDirs)
    add_executable(testMain testmain.cpp testmain.h)
endif()

set_target_properties(testMain PROPERTIES WIN32_EXECUTABLE TRUE)

if(WIN32)
    target_link_options(testMain PRIVATE "/entry:mainCRTStartup")
endif()

target_link_libraries(
    testMain
    PRIVATE Qt${QT_VERSION_MAJOR}::Core Qt${QT_VERSION_MAJOR}::Test qtwidgettestlib::qtwidgettestlib
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(testMain)
endif()

add_test(NAME testMain COMMAND testMain)


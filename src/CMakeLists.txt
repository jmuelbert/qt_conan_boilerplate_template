#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#
#Configuration for all sub - projects
#

cmake_minimum_required(VERSION 3.16..3.24 FATAL_ERROR)

# Set policies
# Make sure that an old version of CMake is not being used so modern features are available
# Update this to the min, max versions that applicable
if(${CMAKE_VERSION} VERSION_LESS 3.24)
	cmake_policy(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})
else()
	cmake_policy(VERSION 3.24)
endif()

include_guard()

# TODO: Set as Build-Master ?
#
#Sub - projects
#

#Libraries
add_subdirectory(lib)

#App
add_subdirectory(apps)


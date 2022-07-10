cmake_minimum_required(VERSION 3.16...3.23 FATAL_ERROR)

#
# Configure CMake environment
#

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Register general cmake commands
include(cmake/Custom.cmake)

# Set policies
set_policy(CMP0054 NEW) # ENABLE CMP0054: Only interpret if() arguments as variables or keywords when unquoted.
set_policy(CMP0042 NEW) # ENABLE CMP0042: MACOSX_RPATH is enabled by default.
set_policy(CMP0063 NEW) # ENABLE CMP0063: Honor visibility properties for all target types.
set_policy(CMP0077 NEW) # ENABLE CMP0077: option() honors normal variables

# Include cmake modules
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GenerateExportHeader)

set(WriterCompilerDetectionHeaderFound NOTFOUND)
# This module is only available with CMake >=3.1, so check whether it could be found
# BUT in CMake 3.1 this module doesn't recognize AppleClang as compiler, so just use it as of CMake 3.2
if(${CMAKE_VERSION} VERSION_GREATER "3.2")
  include(WriteCompilerDetectionHeader OPTIONAL RESULT_VARIABLE WriterCompilerDetectionHeaderFound)
endif()

# Include custom cmake modules
include(cmake/Coverage.cmake)
include(cmake/GenerateTemplateExportHeader.cmake)
include(cmake/GetGitRevisionDescription.cmake)
include(cmake/HealthCheck.cmake)

#
# Project description and (meta) information
#

# Note: by default ENABLE_DEVELOPER_MODE is True
# This means that all analysis (sanitizers, static analysis)
# is enabled and all warnings are treated as errors
# if you want to switch this behavior, change TRUE to FALSE
set(ENABLE_DEVELOPER_MODE
    TRUE
    CACHE BOOL "Enable 'developer mode'")

# Get git revision
get_git_head_revision(GIT_REFSPEC GIT_SHA1)
string(
  SUBSTRING "${GIT_SHA1}"
            0
            12
            GIT_REV)
if(NOT GIT_SHA1)
  set(GIT_REV "0")
endif()

# Meta information about the project
set(META_PROJECT_NAME "qtconanboilerplate")
set(META_PROJECT_DESCRIPTION "CMake QT Conan Boilerplate")
set(META_AUTHOR_ORGANIZATION "Jürgen Mülbert")
set(META_AUTHOR_DOMAIN "https://github.comjmuelbert/qt_conan_boilerplate_template/")
set(META_AUTHOR_MAINTAINER "juergen.muelbert@gmail.com")
set(META_VERSION_MAJOR "0")
set(META_VERSION_MINOR "0")
set(META_VERSION_PATCH "1")
set(META_VERSION_REVISION "${GIT_REV}")
set(META_VERSION "${META_VERSION_MAJOR}.${META_VERSION_MINOR}.${META_VERSION_PATCH}")
set(META_NAME_VERSION "${META_PROJECT_NAME} v${META_VERSION} (${META_VERSION_REVISION})")
set(META_CMAKE_INIT_SHA "${GIT_REV}")

string(MAKE_C_IDENTIFIER ${META_PROJECT_NAME} META_PROJECT_ID)
string(TOUPPER ${META_PROJECT_ID} META_PROJECT_ID)

#
# Project configuration options
#

# Project options
option(BUILD_SHARED_LIBS "Build shared instead of static libraries." ON)
option(OPTION_SELF_CONTAINED "Create a self-contained install with all dependencies." OFF)
option(OPTION_BUILD_TESTS "Build tests." OFF)
option(OPTION_BUILD_DOCS "Build documentation." OFF)
option(OPTION_BUILD_EXAMPLES "Build examples." OFF)
option(OPTION_ENABLE_COVERAGE "Add coverage information." OFF)

#
# Declare project
#

# Generate folders for IDE targets (e.g., VisualStudio solutions)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(IDE_FOLDER "")

# Declare project
project(${META_PROJECT_NAME} C CXX)

# Set output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR})

get_property(BUILDING_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(BUILDING_MULTI_CONFIG)
  if(NOT CMAKE_BUILD_TYPE)
    # Make sure that all supported configuration types have their
    # associated conan packages available. You can reduce this
    # list to only the configuration types you use, but only if one
    # is not forced-set on the command line for VS
    message(TRACE "Setting up multi-config build types")
    set(CMAKE_CONFIGURATION_TYPES
        Debug
        Release
        RelWithDebInfo
        MinSizeRel
        CACHE STRING "Enabled build types" FORCE)
  else()
    message(TRACE "User chose a specific build type, so we are using that")
    set(CMAKE_CONFIGURATION_TYPES
        ${CMAKE_BUILD_TYPE}
        CACHE STRING "Enabled build types" FORCE)
  endif()
endif()

# Create version file
file(WRITE "${PROJECT_BINARY_DIR}/VERSION" "${META_NAME_VERSION}")

#
# Project Health Check Setup
#

# Add cmake-init template check cmake targets
add_check_template_target(${META_CMAKE_INIT_SHA})

# Configure health check tools
enable_cppcheck(ON)
enable_clang_tidy(ON)
enable_coverage(${OPTION_ENABLE_COVERAGE})

#
# Compiler settings and options
#

include(cmake/CompileOptions.cmake)

#
# Deployment/installation setup
#

# Get project name
set(project ${META_PROJECT_NAME})

# Check for system dir install
set(SYSTEM_DIR_INSTALL FALSE)
if("${CMAKE_INSTALL_PREFIX}" STREQUAL "/usr" OR "${CMAKE_INSTALL_PREFIX}" STREQUAL "/usr/local")
  set(SYSTEM_DIR_INSTALL TRUE)
endif()

# Installation paths
if(APPLE)
  set(BUNDLE_APP_NAME ${target})

  # Make sure default prefix on mac is /Applications, dunnow why but it does not default to it
  # probably because we do not enabled built in bundle support in the main project
  string(
    COMPARE EQUAL
            "${CMAKE_INSTALL_PREFIX}"
            "/usr/local"
            CMP_RESULT)
  if(CMP_RESULT)
    set(CMAKE_INSTALL_PREFIX "/Applications")
  endif()

  set(BUNDLE_INSTALL_DIR ".")
  set(RESOURCES_INSTALL_DIR "${BUNDLE_INSTALL_DIR}/${BUNDLE_APP_NAME}/Contents/Resources")
  set(BIN_INSTALL_DIR "${BUNDLE_INSTALL_DIR}/${BUNDLE_APP_NAME}/Contents/MacOS")
  set(LIB_INSTALL_DIR "${BUNDLE_INSTALL_DIR}/${BUNDLE_APP_NAME}/Contents/Frameworks")
  set(PLUGIN_INSTALL_DIR "${BUNDLE_INSTALL_DIR}/${BUNDLE_APP_NAME}/Contents/PlugIns/${META_PROJECT_NAME}")
  set(LIBEXEC_INSTALL_DIR "${BIN_INSTALL_DIR}")
  set(MAN_INSTALL_DIR "${RESOURCES_INSTALL_DIR}/man/man1")
  set(DOC_INSTALL_DIR "${RESOURCES_INSTALL_DIR}/docs")
  set(QCH_INSTALL_DIR "${RESOURCES_INSTALL_DIR}/docs")
  set(TRANSLATION_INSTALL_DIR "${RESOURCES_INSTALL_DIR}/translations")
  set(INCLUDE_INSTALL_DIR "${RESOURCES_INSTALL_DIR}/include/${META_PROJECT_NAME}")
  set(CMAKECONFIG_INSTALL_DIR "${RESOURCES_INSTALL_DIR}/cmake/${META_PROJECT_ID}")
  set(ECM_MKSPECS_INSTALL_DIR "${RESOURCES_INSTALL_DIR}/${ECM_MKSPECS_INSTALL_DIR}")
else()
  # Set installation paths
  # This takes care of installing into "lib64" on distros that use that, for instance,
  # by setting CMAKE_INSTALL_FULL_LIBDIR.
  include(GNUInstallDirs)

  set(BIN_INSTALL_DIR "${CMAKE_INSTALL_BINDIR}") # relative, usually "bin"
  set(LIB_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}") # "lib" or "lib64"
  set(INCLUDE_INSTALL_DIR "${CMAKE_INSTALL_INCLUDEDIR}/${META_PROJECT_NAME}")
  set(CMAKECONFIG_INSTALL_DIR ${LIB_INSTALL_DIR}/cmake/${META_PROJECT_ID})
  set(DATAROOTDIR
      "${CMAKE_INSTALL_DATAROOTDIR}"
      CACHE PATH "Define install directory for read-only architecture-independent data")
  set(XDG_APPS_INSTALL_DIR "${DATAROOTDIR}/applications")
  set(APPDATA_INSTALL_DIR "${DATAROOTDIR}/metainfo")
  set(ICON_INSTALL_DIR "${DATAROOTDIR}/icons")
  set(MAN_INSTALL_DIR "${DATAROOTDIR}/man/man1")
  set(QCH_INSTALL_DIR
      "${CMAKE_INSTALL_DOCDIR}"
      CACHE PATH "Install location of Qt Assistant help files.")
  if(WIN32)
    set(PLUGIN_INSTALL_DIR "plugins/${META_PROJECT_NAME}")
    set(LIBEXEC_INSTALL_DIR "${BIN_INSTALL_DIR}")
    set(DOC_INSTALL_DIR .)
    set(TRANSLATION_INSTALL_DIR "translations")
  else()
    set(PLUGIN_INSTALL_DIR "${LIB_INSTALL_DIR}/${META_PROJECT_NAME}")
    set(LIBEXEC_INSTALL_DIR "${LIB_INSTALL_DIR}/${META_PROJECT_NAME}/libexec")
    set(DOC_INSTALL_DIR "${DATAROOTDIR}/doc/${META_PROJECT_NAME}/")
    set(TRANSLATION_INSTALL_DIR "${DATAROOTDIR}/${META_PROJECT_NAME}/translations")
  endif()
endif()

set(INSTALL_TARGETS_DEFAULT_ARGS
    RUNTIME
    DESTINATION
    ${BIN_INSTALL_DIR}
    LIBRARY
    DESTINATION
    ${LIB_INSTALL_DIR}
    ARCHIVE
    DESTINATION
    ${LIB_INSTALL_DIR}
    COMPONENT
    Devel
    BUNDLE
    DESTINATION
    ${BUNDLE_INSTALL_DIR})

# Set runtime path
set(CMAKE_SKIP_BUILD_RPATH FALSE) # Add absolute path to all dependencies for BUILD
set(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) # Use CMAKE_INSTALL_RPATH for INSTALL
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE) # Do NOT add path to dependencies for INSTALL

if(NOT SYSTEM_DIR_INSTALL)
  # Find libraries relative to binary
  if(APPLE)
    set(EXECUTABLE_INSTALL_RPATH "@loader_path/../../../${INSTALL_LIB}")
    set(LIBRARY_INSTALL_RPATH "@loader_path/../../../${INSTALL_LIB}")
  else()
    set(EXECUTABLE_INSTALL_RPATH "$ORIGIN/${INSTALL_LIB}")
    set(LIBRARY_INSTALL_RPATH "$ORIGIN")
  endif()
endif()

#
# Project modules
#

add_subdirectory(src)
add_subdirectory(docs)
add_subdirectory(deploy)

# Tests
if(OPTION_BUILD_TESTS)
  set(IDE_FOLDER "Tests")
  enable_testing()
  add_subdirectory(test)
endif()

#
# Deployment (global project files)
#

# Install version file
install(
  FILES "${PROJECT_BINARY_DIR}/VERSION"
  DESTINATION ${BIN_INSTALL_DIR}
  COMPONENT runtime)

# Install cmake find script for the project
install(
  FILES ${META_PROJECT_NAME}-config.cmake
  DESTINATION ${BIN_INSTALL_DIR}
  COMPONENT dev)

# Install the project meta files
install(
  FILES AUTHORS
  DESTINATION ${BIN_INSTALL_DIR}
  COMPONENT runtime)
install(
  FILES LICENSE
  DESTINATION ${BIN_INSTALL_DIR}
  COMPONENT runtime)
install(
  FILES README.md
  DESTINATION ${BIN_INSTALL_DIR}
  COMPONENT runtime)

if(APPLE)
  # Install runtime data
  install(
    DIRECTORY ${PROJECT_SOURCE_DIR}/data
    DESTINATION ${RESOURCES_INSTALL_DIR}
    COMPONENT runtime)
else()
  install(
    DIRECTORY ${PROJECT_SOURCE_DIR}/data
    DESTINATION ${APPDATA_INSTALL_DIR}
    COMPONENT runtime)
endif()

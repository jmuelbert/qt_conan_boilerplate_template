#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#

#
# App name and options
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

project(
    qtwidgettestlib
    VERSION 0.0.2
    LANGUAGES CXX
)

include_guard()

set(PROJECT_PREFIX QTWIDGETTEST_LIB_)

option(${PROJECT_PREFIX}AS_SYSTEM_HEADERS "Exports library as system HEADERS" OFF)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

include(GenerateExportHeader)
include(CMakePackageConfigHelpers)

#
# SOURCES
#
set(INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}")
set(SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/source")

set(HEADERS ${INCLUDE_PATH}/MyClass.h)
set(SOURCES ${SOURCE_PATH}/MyClass.cpp)

find_package(
    QT
    NAMES
    Qt6
    Qt5
    REQUIRED
    COMPONENTS Core
)

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

#
# Create library
#

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    if(${QT_VERSION_MINOR} GREATER_EQUAL 3)
        qt_standard_project_setup()
    else()
        set(CMAKE_AUTOMOC ON)
        set(CMAKE_AUTOUIC ON)
        include(GNUInstallDirs)
    endif()
    qt_add_library(${PROJECT_NAME} "" MANUAL_FINALIZATION)
    # Define PROJECT_NAME properties for Android with Qt 6 as:
    #    set_property(PROJECT_NAME ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
    #                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
    # For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#PROJECT_NAME-creation
else()
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTOUIC ON)
    include(GNUInstallDirs)
    add_library(${PROJECT_NAME} "")
endif()

# Create namespaced alias
add_library(
    ${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME}
)

# Add SOURCES to the project
target_sources(${PROJECT_NAME} PRIVATE ${SOURCES} ${HEADERS} ${MOC_SOURCE_FILES})

# Set API export file and macro
string(MAKE_C_IDENTIFIER ${PROJECT_NAME} target_id)
string(TOUPPER ${target_id} target_id)
set(FEATURE_FILE "include/${PROJECT_NAME}/${PROJECT_NAME}_features.h")
set(EXPORT_FILE "include/${PROJECT_NAME}/${PROJECT_NAME}_export.h")
set(TEMPLATE_EXPORT_FILE"include/${PROEJECT_NAME}/${PROJETC_NAME}_api.h")
set(EXPORT_MACRO "${target_id}_API")

#
# Include directories
#

# Export library for downstream projects
export(
    TARGETS ${PROJECT_NAME}
    NAMESPACE ${META_PROJECT_NAME}::
    FILE ${PROJECT_BINARY_DIR}/cmake/${PROJECT_NAME}/${PROJECT_NAME}-export.cmake
)

# Create feature detection header
# Compilers:
#  https://cmake.org/cmake/help/v3.1/variable/CMAKE_LANG_COMPILER_ID.html#variable:CMAKE_%3CLANG%3E_COMPILER_ID
# Feature: https://cmake.org/cmake/help/v3.1/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html

# Check for availability of module; use pre-generated version if not found
if(WriterCompilerDetectionHeaderFound)
    write_compiler_detection_header(
        FILE ${FEATURE_FILE} PREFIX ${PROJECT_NAME_ID}
        COMPILERS AppleClang Clang GNU MSVC
        FEATURES cxx_alignas
                 cxx_alignof
                 cxx_constexpr
                 cxx_final
                 cxx_noexcept
                 cxx_nullptr
                 cxx_sizeof_member
                 cxx_thread_local
        VERSION 3.2
    )
else()
    file(
        COPY ${PROJECT_SOURCE_DIR}/codegeneration/${PROJECT_NAME}_features.h
        DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/include/${PROJECT_NAME}
        USE_SOURCE_PERMISSIONS
    )
endif()

#
# Project options
#
set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES INSTALL_RPATH "${LIBRARY_INSTALL_RPATH}"
               FOLDER "${IDE_FOLDER}"
               VERSION "${PROJECT_VERSION}"
               SOVERSION "${PROJECT_VERSION_MAJOR}"
)
#
# Include directories
#

target_include_directories(
    ${PROJECT_NAME}
    PRIVATE ${PROJECT_BINARY_DIR}/source/include ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR}/include
    PUBLIC ${DEFAULT_INCLUDE_DIRECTORIES}
    INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
              $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include> $<INSTALL_INTERFACE:include>
)

#
# Libraries
#

target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE
    PUBLIC ${DEFAULT_LIBRARIES} Qt${QT_VERSION_MAJOR}::Core
    INTERFACE
)

#
# Compile definitions
#

target_compile_definitions(
    ${PROJECT_NAME}
    PRIVATE
    PUBLIC $<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:${target_id}_STATIC_DEFINE> ${DEFAULT_COMPILE_DEFINITIONS}
    INTERFACE
)

#
# Compile options
#

target_compile_options(
    ${PROJECT_NAME}
    PRIVATE
    PUBLIC ${DEFAULT_COMPILE_OPTIONS}
    INTERFACE
)

#
# Linker options
#

target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE
    PUBLIC ${DEFAULT_LINKER_OPTIONS}
    INTERFACE
)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_finalize_target(${PROJECT_NAME})
endif()

#
# Deployment
#

# Create API export header
generate_export_header(
    ${PROJECT_NAME}
    EXPORT_FILE_NAME
    ${EXPORT_FILE}
    EXPORT_MACRO_NAME
    ${EXPORT_MACRO}
)

# Installing the library
install(
    TARGETS ${PROJECT_NAME}
    EXPORT "${PROJECT_NAME}-config"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}" COMPONENT Runtime
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT "${PROJECT_NAME}-dev"
    PUBLIC_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}"
    PRIVATE_HEADER DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}"
    INCLUDES
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}"
    COMPONENT Dev
)

install(
    EXPORT "${PROJECT_NAME}-config"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
)

# Tests
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
endif()

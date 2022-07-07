#
# External dependencies
#

# find_package(THIRDPARTY REQUIRED)

#
# Library name and options
#

# Target name
set(target myclass)

# Exit here if required dependencies are not met
message(STATUS "Lib ${target}")

# Set API export file and macro
string(MAKE_C_IDENTIFIER ${target} target_id)
string(TOUPPER ${target_id} target_id)
set(feature_file "include/${target}/${target}_features.h")
set(export_file "include/${target}/${target}_export.h")
set(template_export_file "include/${target}/${target}_api.h")
set(export_macro "${target_id}_API")

#
# Sources
#

set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${target}")
set(source_path "${CMAKE_CURRENT_SOURCE_DIR}/source")

set(headers ${include_path}/MyClass.h)

set(sources ${source_path}/MyClass.cpp)

# Group source files
set(header_group "Header Files (API)")
set(source_group "Source Files")
source_group_by_path(
  ${include_path}
  "\\\\.h$|\\\\.hpp$"
  ${header_group}
  ${headers})
source_group_by_path(
  ${source_path}
  "\\\\.cpp$|\\\\.c$|\\\\.h$|\\\\.hpp$"
  ${source_group}
  ${sources})

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

#
# Create library
#

find_package(
  QT
  NAMES
  Qt6
  Qt5
  REQUIRED
  COMPONENTS Core)

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Core)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
  qt_standard_project_setup()
  qt_add_library(
    ${target}
    STATIC
    ""
    MANUAL_FINALIZATION)
else()
  add_library(${target} STATIC "")
endif()

# Create namespaced alias
add_library(${META_PROJECT_NAME}::${target} ALIAS ${target})

target_sources(${target} PRIVATE ${sources} ${headers} ${MOC_SOURCE_FILES})
#
# Include directories
#

# Export library for downstream projects
export(
  TARGETS ${target}
  NAMESPACE ${META_PROJECT_NAME}::
  FILE ${PROJECT_BINARY_DIR}/cmake/${target}/${target}-export.cmake)

# Create feature detection header
# Compilers: https://cmake.org/cmake/help/v3.1/variable/CMAKE_LANG_COMPILER_ID.html#variable:CMAKE_%3CLANG%3E_COMPILER_ID
# Feature: https://cmake.org/cmake/help/v3.1/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html

# Check for availability of module; use pre-generated version if not found
if(WriterCompilerDetectionHeaderFound)
  write_compiler_detection_header(
    FILE
    ${feature_file}
    PREFIX
    ${target_id}
    COMPILERS AppleClang
              Clang
              GNU
              MSVC
    FEATURES cxx_alignas
             cxx_alignof
             cxx_constexpr
             cxx_final
             cxx_noexcept
             cxx_nullptr
             cxx_sizeof_member
             cxx_thread_local
    VERSION 3.2)
else()
  file(
    COPY ${PROJECT_SOURCE_DIR}/src/codegeneration/${target}_features.h
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/include/${target}
    USE_SOURCE_PERMISSIONS)
endif()

# Create API export header
generate_export_header(
  ${target}
  EXPORT_FILE_NAME
  ${export_file}
  EXPORT_MACRO_NAME
  ${export_macro})

generate_template_export_header(${target} ${target_id} ${template_export_file})

#
# Project options
#

set_target_properties(
  ${target}
  PROPERTIES ${DEFAULT_PROJECT_OPTIONS} INSTALL_RPATH
             "${LIBRARY_INSTALL_RPATH}" FOLDER
             "${IDE_FOLDER}" VERSION
             "${META_VERSION}" SOVERSION
             "${META_VERSION_MAJOR}")

#
# Include directories
#

target_include_directories(
  ${target}
  PRIVATE ${PROJECT_BINARY_DIR}/source/include ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR}/include
  PUBLIC ${DEFAULT_INCLUDE_DIRECTORIES}
  INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include> $<INSTALL_INTERFACE:include>)

#
# Libraries
#

target_link_libraries(
  ${target}
  PRIVATE
  PUBLIC ${DEFAULT_LIBRARIES} Qt6::Core
  INTERFACE)

#
# Compile definitions
#

target_compile_definitions(
  ${target}
  PRIVATE
  PUBLIC $<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:${target_id}_STATIC_DEFINE> ${DEFAULT_COMPILE_DEFINITIONS}
  INTERFACE)

#
# Compile options
#

target_compile_options(
  ${target}
  PRIVATE
  PUBLIC ${DEFAULT_COMPILE_OPTIONS}
  INTERFACE)

#
# Linker options
#

target_link_libraries(
  ${target}
  PRIVATE
  PUBLIC ${DEFAULT_LINKER_OPTIONS}
  INTERFACE)

qt_finalize_target(${target})

#
# Target Health
#

perform_health_checks(${target} ${sources} ${headers})

#
# Deployment
#

# Library
install(
  TARGETS ${target}
  EXPORT "${target}-export"
  COMPONENT dev
  RUNTIME DESTINATION ${BIN_INSTALL_DIR} COMPONENT runtime
  LIBRARY DESTINATION ${LIB_INSTALL_DIR} COMPONENT runtime
  ARCHIVE DESTINATION ${LIB_INSTALL_DIR} COMPONENT dev)

# Header files
install(
  DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/${target}
  DESTINATION ${INCLUDE_INSTALL_DIR}
  COMPONENT dev)

# Generated header files
install(
  DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/${target}
  DESTINATION ${INCLUDE_INSTALL_DIR}
  COMPONENT dev)

# CMake config
install(
  EXPORT ${target}-export
  NAMESPACE ${META_PROJECT_NAME}::
  DESTINATION ${INSTALL_CMAKE}/${target}
  COMPONENT dev)

# Tests
if(OPTION_BUILD_TESTS)
  set(IDE_FOLDER "Tests")
  enable_testing()
  add_subdirectory(test)
endif()

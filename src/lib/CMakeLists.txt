include(CMakePackageConfigHelpers)
include(CMakeFindDependencyMacro)
include(GenerateExportHeader)
include(GNUInstallDirs)

find_package(
  Qt6
  COMPONENTS Core
  REQUIRED)

set(SOURCE_FILES MyClass.cpp)

set(MOC_HEADERS)

set(HEADER_FILES MyClass.h ${MOC_HEADERS})

qt_add_library(
  MyLib
  STATIC
  ""
  MANUAL_FINALIZATION)

add_library(MyLib::MyLib ALIAS MyLib)

target_sources(MyLib PRIVATE ${SOURCE_FILES} ${HEADER_FILES} ${MOC_SOURCE_FILES})

target_include_directories(MyLib INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
                                           "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

target_link_libraries(MyLib PUBLIC Qt6::Core)

qt_finalize_target(MyLib)

generate_export_header(MyLib)
#
# Install instructions
#
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib)

install(
  TARGETS MyLib
  EXPORT MyLib-Targets
  RUNTIME DESTINATION "${BIN_INSTALL_DIR}"
  LIBRARY DESTINATION "${LIB_INSTALL_DIR}"
  ARCHIVE DESTINATION "${LIB_INSTALL_DIR}")

install(FILES MyClass.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(
  EXPORT MyLib-Targets
  FILE MyLibTargets.cmake
  NAMESPACE MyLib::
  DESTINATION ${INSTALL_CONFIGDIR})

export(
  EXPORT MyLib-Targets
  FILE ${INSTALL_CONFIGDIR}/MyLibTargets.cmake
  NAMESPACE MyLib::)

add_subdirectory(test)

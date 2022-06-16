cmake_minimum_required(VERSION 3.15...3.23)

find_package(
  Qt6
  COMPONENTS Test
  REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

qt_add_executable(
  testMain
  MANUAL_FINALIZATION
  testmain.cpp
  testmain.h)

set_target_properties(testMain PROPERTIES WIN32_EXECUTABLE TRUE)

if(WIN32)
  target_link_options(testMain PRIVATE "/entry:mainCRTStartup")
endif()

add_test(NAME testMain COMMAND testMain)

if(WIN32 OR APPLE)
  set_tests_properties(testMain PROPERTIES ENVIRONMENT "PATH=${CONAN_BIN_DIRS_QT}\;$ENV{PATH}")
endif()

target_link_libraries(
  testMain
  PRIVATE Qt6::Test
          MyLib::MyLib
          myproject::project_options
          myproject::project_warnings)

qt_finalize_executable(testMain)

if(APPLE)
  # Since there appear to exist problems with NOT setting the RPATH when building
  # by enabling CMAKE_KEEP_RPATH and others, we just set the libs absolute paths
  # to the conan lib dir.

  function(
    ChangeRPath
    target
    file
    new)
    add_custom_command(
      TARGET testMain
      POST_BUILD
      COMMAND ${CMAKE_INSTALL_NAME_TOOL} -change @rpath/${file} ${new}/${file} $<TARGET_FILE:testMain>)
  endfunction()

  foreach(qt_lib IN LISTS CONAN_LIBS_QT)
    changerpath(testMain lib${qt_lib}.6.dylib ${CONAN_LIB_DIRS_QT})
  endforeach()
endif()
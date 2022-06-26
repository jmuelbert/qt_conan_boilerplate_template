cmake_minimum_required(VERSION 3.5)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)
find_package(CLI11 CONFIG REQUIRED)

find_package(
  QT
  NAMES
  Qt6
  Qt5
  REQUIRED
  COMPONENTS Widgets LinguistTools)

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets LinguistTools)

set(TS_FILES QtWidgetTest_de_DE.ts)

set(PROJECT_SOURCES
    main.cpp
    mainwindow.cpp
    mainwindow.h
    mainwindow.ui
    ${TS_FILES})

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
  qt_add_executable(QtWidgetTest MANUAL_FINALIZATION ${PROJECT_SOURCES})
  # Define target properties for Android with Qt 6 as:
  #    set_property(TARGET QtWidgetTest APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
  #                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
  # For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation

  qt_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
else()
  if(ANDROID)
    add_library(QtWidgetTest SHARED ${PROJECT_SOURCES})
    # Define properties for Android with Qt 5 after find_package() calls as:
    #    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
  else()
    add_executable(QtWidgetTest ${PROJECT_SOURCES})
  endif()

  qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
endif()

target_link_libraries(
  QtWidgetTest
  PUBLIC project_options project_warnings
  PRIVATE CLI11::CLI11
          fmt::fmt
          spdlog::spdlog
          Qt${QT_VERSION_MAJOR}::Widgets)

set_target_properties(
  QtWidgetTest
  PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
             MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
             MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
             MACOSX_BUNDLE TRUE
             WIN32_EXECUTABLE TRUE)

target_include_directories(QtWidgetTest PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

if(QT_VERSION_MAJOR EQUAL 6)
  qt_finalize_executable(QtWidgetTest)
endif()

if(WIN32)
  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.rc.in ${PROJECT_BINARY_DIR}/app.rc @ONLY)

  install(TARGETS QtWidgetTest ${INSTALL_TARGETS_DEFAULT_ARGS})
  add_custom_command(
    TARGET QtWidgetTest
    POST_BUILD
    COMMAND ${Qt6_DIR}/../../../bin/windeployqt ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.exe --compiler-runtime --verbose 2
            --dir ${CMAKE_BINARY_DIR}/winqt/)

  # See
  # https://cmake.org/cmake/help/v3.15/prop_tgt/MACOSX_BUNDLE_INFO_PLIST.html

elseif(APPLE)
  set_target_properties(QtWidgetTest PROPERTIES OUTPUT_NAME QtWidgetTest INSTALL_RPATH "@executable_path/../Frameworks")

  set_property(TARGET QtWidgetTest PROPERTY MACOSX_BUNDLE_INFO_PLIST
                                            ${CMAKE_SOURCE_DIR}/cmake/modules/MacOSXBundleInfo.plist.in)

  # the MacOSX bundle display name property (CFBundleDisplayName) is not
  # currently supported by cmake, so has to be set for all targets in this cmake
  # file
  set(MACOSX_BUNDLE_DISPLAY_NAME QtWidgetTest)
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER "io.github.jmuelbert.QtWidgetTest")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_BUNDLE_NAME "QtWidgetTest")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_DISPLAY_NAME "QtWidgetTest")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_INFO_STRING "QtWidgetTest - A Test program")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_LONG_VERSION_STRING "QtWidgetTest ${PROJECT_VERSION}")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_ICON_FILE "${ICONS_SOURCES}")
  set_target_properties(QtWidgetTest PROPERTIES MACOSX_BUNDLE_COPYRIGHT "2022 Jürgen Mülbert")

  install(
    TARGETS QtWidgetTest
    BUNDLE DESTINATION . COMPONENT Runtime
    RUNTIME DESTINATION bin COMPONENT Runtime)

  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/package_dmg.json.in ${CMAKE_CURRENT_BINARY_DIR}/package_dmg.json
                 @ONLY)

  add_custom_command(
    TARGET QtWidgetTest
    POST_BUILD
    COMMAND ${Qt6_DIR}/../../../bin/macdeployqt ${CMAKE_BINARY_DIR}/QtWidgetTest.app)

elseif(UNIX AND NOT APPLE)
  # appdata
  include(GNUInstallDirs)

  install(TARGETS QtWidgetTest ${INSTALL_TARGETS_DEFAULT_ARGS})

  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/appdata.xml.in
                 ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.appdata.xml @ONLY)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.appdata.xml
          DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/metainfo")

  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.desktop.in
                 ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.desktop @ONLY)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.desktop
          DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/applications")

  install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png"
          DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/${PROJECT_NAME}.png")
  # man page
  find_program(GZIP gzip)
  if(GZIP)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.1.in ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1 @ONLY)
    add_custom_command(
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1.gz
      COMMAND ${GZIP} -c ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1 > QtWidgetTest.1.gz
      COMMENT "Create the bin gz archive"
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1)
    add_custom_target(
      man ALL
      COMMENT "Create man-file"
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1.gz)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1.gz DESTINATION "${CMAKE_INSTALL_MANDIR}/man1")
  endif()
endif()

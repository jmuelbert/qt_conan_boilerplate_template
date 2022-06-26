cmake_minimum_required(VERSION 3.16)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
    mainwindow.ui)

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
  qt_standard_project_setup()
  qt_add_executable(${PROJECT_NAME} MANUAL_FINALIZATION ${PROJECT_SOURCES})
  # Define target properties for Android with Qt 6 as:
  #    set_property(TARGET ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
  #                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
  # For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#target-creation

  qt_add_translations(${PROJECT_NAME} TS_FILES ${TS_FILES})
  qt_add_resources(
    ${PROJECT_NAME}
    "translations"
    PREFIX
    "/i18n"
    BASE
    "${CMAKE_CURRENT_BINARY_DIR}"
    FILES
    "${qm_files}")
else()
  if(ANDROID)
    add_library(${PROJECT_NAME} SHARED ${PROJECT_SOURCES})
    # Define properties for Android with Qt 5 after find_package() calls as:
    #    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
  else()
    add_executable(${PROJECT_NAME} ${PROJECT_SOURCES})
  endif()

  qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})
endif()

# App bundles on macOS have an .app suffix
if(APPLE)
  set(executable_path "$<TARGET_FILE_NAME:${PROJECT_NAME}>.app")
else()
  set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
endif()

target_link_libraries(
  ${PROJECT_NAME}
  PUBLIC project_options project_warnings
  PRIVATE CLI11::CLI11
          fmt::fmt
          spdlog::spdlog
          Qt${QT_VERSION_MAJOR}::Widgets)

set_target_properties(
  ${PROJECT_NAME}
  PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
             MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
             MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
             MACOSX_BUNDLE TRUE
             WIN32_EXECUTABLE TRUE)

target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

if(QT_VERSION_MAJOR EQUAL 6)
  qt_finalize_executable(${PROJECT_NAME})
endif()

# The following script must only be executed at install time
set(deploy_script "${CMAKE_CURRENT_BINARY_DIR}/deploy_${PROJECT_NAME}.cmake")

file(
  GENERATE
  OUTPUT ${deploy_script}
  CONTENT
    "
# Including the file pointed to by QT_DEPLOY_SUPPORT ensures the generated
# deployment script has access to qt_deploy_runtime_dependencies()
include(\"${QT_DEPLOY_SUPPORT}\")
qt_deploy_runtime_dependencies(
    EXECUTABLE \"${executable_path}\"
    # ADDITIONAL_EXECUTABLES \"${helper_app_path}\"
    GENERATE_QT_CONF
    VERBOSE
)")

# Omitting RUNTIME DESTINATION will install a non-bundle target to CMAKE_INSTALL_BINDIR,
# which coincides with the default value of QT_DEPLOY_BIN_DIR used above, './bin'.
# Installing macOS bundles always requires an explicit BUNDLE DESTINATION option.
install(TARGETS ${PROJECT_NAME} # Install to CMAKE_INSTALL_PREFIX/bin/MyApp.exe
                                #                           and ./binHelperApp.exe
        BUNDLE DESTINATION . # Install to CMAKE_INSTALL_PREFIX/MyApp.app/Contents/MacOS/MyApp
)
install(SCRIPT ${deploy_script}) # Add its runtime dependencies

# if(WIN32)
#   configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.rc.in ${PROJECT_BINARY_DIR}/app.rc @ONLY)

#   install(TARGETS ${PROJECT_NAME} ${INSTALL_TARGETS_DEFAULT_ARGS})

#   install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png"
#     DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}")

#   add_custom_command(
#     TARGET ${PROJECT_NAME}
#     POST_BUILD
#     COMMAND ${Qt6_DIR}/../../../bin/windeployqt ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.exe --compiler-runtime --verbose 2
#             --dir ${CMAKE_BINARY_DIR}/winqt/)

#   # See
#   # https://cmake.org/cmake/help/v3.15/prop_tgt/MACOSX_BUNDLE_INFO_PLIST.html

# elseif(APPLE)
#   set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME ${PROJECT_NAME} INSTALL_RPATH
#                                                                                "@executable_path/../Frameworks")

#   set_property(TARGET ${PROJECT_NAME} PROPERTY MACOSX_BUNDLE_INFO_PLIST
#                                                ${CMAKE_SOURCE_DIR}/cmake/modules/MacOSXBundleInfo.plist.in)

#   # the MacOSX bundle display name property (CFBundleDisplayName) is not
#   # currently supported by cmake, so has to be set for all targets in this cmake
#   # file
#   set(MACOSX_BUNDLE_DISPLAY_NAME ${PROJECT_NAME})
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_GUI_IDENTIFIER "io.github.jmuelbert.${PROJECT_NAME}")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_DISPLAY_NAME "${PROJECT_NAME}")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_INFO_STRING "${PROJECT_NAME} - A Test program")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_LONG_VERSION_STRING
#                                                    "${PROJECT_NAME} ${PROJECT_VERSION}")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_ICON_FILE "${ICONS_SOURCES}")
#   set_target_properties(${PROJECT_NAME} PROPERTIES MACOSX_BUNDLE_COPYRIGHT "2022 Jürgen Mülbert")

#   install(
#     TARGETS ${PROJECT_NAME}
#     BUNDLE DESTINATION . COMPONENT Runtime
#     RUNTIME DESTINATION bin COMPONENT Runtime)

#   install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png"
#       DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}")

#   install(FILES ${qm_files} DESTINATION "translations")

#   configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/package_dmg.json.in ${CMAKE_CURRENT_BINARY_DIR}/package_dmg.json
#                  @ONLY)

#   # add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD COMMAND
#   #   ${Qt6_DIR}/../../../bin/macdeployqt ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.app)

# elseif(UNIX AND NOT APPLE)
#   # appdata
#   # GNUInstallDirs is called from qt_standard_settings()

#   install(TARGETS ${PROJECT_NAME} ${INSTALL_TARGETS_DEFAULT_ARGS})

#   configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/appdata.xml.in
#                  ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.appdata.xml @ONLY)
#   install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.appdata.xml
#           DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/metainfo")

#   configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.desktop.in
#                  ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.desktop @ONLY)
#   install(FILES ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.desktop
#           DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/applications")

#   install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png"
#           DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/${PROJECT_NAME}")
#   # man page
#   find_program(GZIP gzip)
#   if(GZIP)
#     configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.1.in ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1 @ONLY)
#     add_custom_command(
#       OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1.gz
#       COMMAND ${GZIP} -c ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1 > ${PROJECT_NAME}.1.gz
#       COMMENT "Create the bin gz archive"
#       DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1)
#     add_custom_target(
#       man ALL
#       COMMENT "Create man-file"
#       DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1.gz)
#     install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1.gz DESTINATION "${CMAKE_INSTALL_MANDIR}/man1")
#   endif()
# endif()

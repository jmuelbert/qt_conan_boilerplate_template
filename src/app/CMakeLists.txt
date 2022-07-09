#
# External dependencies
#

# find_package(THIRDPARTY REQUIRED)

#
# App name and options
#

# TARGET name
set(TARGET qtwidgettest)

# Exit here if required dependencies are not met
message(STATUS "App ${TARGE}")

# Set API export file and macro
string(MAKE_C_IDENTIFIER ${TARGET} TARGET_ID)
string(TOUPPER ${TARGET_ID} TARGET_ID)
set(feature_file "include/${TARGET}/${TARGET}_features.h")
set(export_file "include/${TARGET}/${TARGET}_export.h")
set(template_export_file "include/${TARGET}/${TARGET}_api.h")
set(export_macro "${TARGET_ID}_API")

#
# Sources
#

set(include_path "${CMAKE_CURRENT_SOURCE_DIR}/include/${TARGET}")
set(source_path "${CMAKE_CURRENT_SOURCE_DIR}/source")

set(headers ${include_path}/mainwindow.h)

set(sources ${source_path}/main.cpp ${source_path}/mainwindow.cpp ${source_path}/mainwindow.ui)

set(TS_FILES translations/QtWidgetTest_de_DE.ts)

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

find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

find_package(
  QT
  NAMES
  Qt6
  Qt5
  REQUIRED
  COMPONENTS Widgets LinguistTools)

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets LinguistTools)

#
# Create app
#

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
  qt_standard_project_setup()
  qt_add_executable(
    ${TARGET}
    WIN32
    MACOSX_BUNDLE
    MANUAL_FINALIZATION
    ${sources}
    ${headers})
  # Define TARGET properties for Android with Qt 6 as:
  #    set_property(TARGET ${TARGET} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
  #                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
  # For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#TARGET-creation

  qt_add_translations(${TARGET} TS_FILES ${TS_FILES})
  qt_add_resources(
    ${TARGET}
    "translations"
    PREFIX
    "/i18n"
    BASE
    "${CMAKE_CURRENT_BINARY_DIR}"
    FILES
    "${qm_files}")
else()
  if(ANDROID)
    add_library(${TARGET} SHARED ${sources} ${headers})
    # Define properties for Android with Qt 5 after find_package() calls as:
    #    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
  else()
    add_executable(${TARGET} WIN32 MACOSX_BUNDLE ${sources} ${headers})
  endif()
  set(TS_FILES translations/QtWidgetTest_de_DE.ts)
  set_source_files_properties(
    ${TS_FILES}
    ROPERTIES
    OUTPUT_LOCATION
    "${CMAKE_CURRENT_BINARY_DIR}/translations")
  qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})

endif()

# Create feature detection header
# Compilers: https://cmake.org/cmake/help/v3.1/variable/CMAKE_LANG_COMPILER_ID.html#variable:CMAKE_%3CLANG%3E_COMPILER_ID
# Feature: https://cmake.org/cmake/help/v3.1/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html

# Check for availability of module; use pre-generated version if not found
if(WriterCompilerDetectionHeaderFound)
  write_compiler_detection_header(
    FILE
    ${feature_file}
    PREFIX
    ${TARGET_ID}
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
    COPY ${PROJECT_SOURCE_DIR}/src/codegeneration/${TARGET}_features.h
    DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/include/${TARGET}
    USE_SOURCE_PERMISSIONS)
endif()

#
# Project options
#

set_target_properties(
  ${TARGET}
  PROPERTIES ${DEFAULT_PROJECT_OPTIONS} INSTALL_RPATH
             "${LIBRARY_INSTALL_RPATH}" FOLDER
             "${IDE_FOLDER}")

#
# Include directories
#

target_include_directories(
  ${TARGET}
  PRIVATE ${PROJECT_BINARY_DIR}/src/include ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR}/include
  PUBLIC ${DEFAULT_INCLUDE_DIRECTORIES}
  INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include> $<INSTALL_INTERFACE:include>)

#
# Libraries
#

target_link_libraries(
  ${TARGET}
  PRIVATE
  PUBLIC ${DEFAULT_LIBRARIES}
  INTERFACE)

#
# Compile definitions
#

target_compile_definitions(
  ${TARGET}
  PRIVATE
  PUBLIC $<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:${TARGET_ID}_STATIC_DEFINE> ${DEFAULT_COMPILE_DEFINITIONS}
  INTERFACE)

#
# Compile options
#

target_compile_options(
  ${TARGET}
  PRIVATE
  PUBLIC ${DEFAULT_COMPILE_OPTIONS}
  INTERFACE)

#
# Linker options
#

target_link_libraries(
  ${TARGET}
  PRIVATE fmt::fmt spdlog::spdlog Qt${QT_VERSION_MAJOR}::Widgets
  PUBLIC ${DEFAULT_LINKER_OPTIONS}
  INTERFACE)

if(QT_VERSION_MAJOR EQUAL 6)
  qt_finalize_executable(${TARGET})
endif()

#
# TARGET Health
#

perform_health_checks(${TARGET} ${sources} ${headers})

#
# Deployment
#

if(APPLE OR WIN32)

  if(APPLE)

    set(executable_path "$<TARGET_FILE_NAME:${TARGET}>.app")

    set_property(TARGET ${TARGET} PROPERTY MACOSX_BUNDLE_INFO_PLIST
                                           ${CMAKE_SOURCE_DIR}/cmake/modules/MacOSXBundleInfo.plist.in)

    # the MacOSX bundle display name property (CFBundleDisplayName) is not
    # currently supported by cmake, so has to be set for all TARGETs in this cmake
    # file
    set(MACOSX_BUNDLE_DISPLAY_NAME ${TARGET})
    set_target_properties(
      ${TARGET}
      PROPERTIES BUNDLE True
                 MACOSX_BUNDLE_GUI_IDENTIFIER "io.github.jmuelbert.${TARGET}"
                 MACOSX_BUNDLE_BUNDLE_NAME "${TARGET}"
      PROPERTIES MACOSX_BUNDLE_DISPLAY_NAME "${TARGET}"
                 MACOSX_BUNDLE_INFO_STRING "${TARGET} - A Test program"
                 MACOSX_BUNDLE_LONG_VERSION_STRING "${TARGET} ${META_VERSION}"
                 MACOSX_BUNDLE_SHORT_VERSION_STRING "${META_VERSION}"
                 MACOSX_BUNDLE_BUNDLE_VERSION "${META_VERSION}"
      PROPERTIES MACOSX_BUNDLE_ICON_FILE "${ICONS_SOURCES}" MACOSX_BUNDLE_COPYRIGHT "2022 ${META_AUTHOR_ORGANIZATION}")

    install(TARGETS ${TARGET} BUNDLE DESTINATION . COMPONENT Runtime)

    install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png" DESTINATION ${RESOURCES_INSTALL_DIR})

    install(FILES ${qm_files} DESTINATION ${TRANSLATION_INSTALL_DIR})

    configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/package_dmg.json.in ${CMAKE_CURRENT_BINARY_DIR}/package_dmg.json
                   @ONLY)

  elseif(WIN32)
    set(executable_path "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${TARGET}>")
    configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.rc.in ${PROJECT_BINARY_DIR}/app.rc @ONLY)

    install(TARGETS ${TARGET} ${INSTALL_TARGETS_DEFAULT_ARGS})

    install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png" DESTINATION "${ICON_INSTALL_DIR}")

    install(FILES ${qm_files} DESTINATION ${TRANSLATION_INSTALL_DIR})
  endif()
  # The following script must only be executed at install time
  set(deploy_script "${CMAKE_CURRENT_BINARY_DIR}/deploy_${TARGET}.cmake")

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
  install(SCRIPT ${deploy_script}) # Add its runtime dependencies
elseif(UNIX AND NOT APPLE)
  # appdata
  # GNUInstallDirs is called from qt_standard_settings()

  install(TARGETS ${TARGET} ${INSTALL_TARGETS_DEFAULT_ARGS})

  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/appdata.xml.in ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.appdata.xml
                 @ONLY)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.appdata.xml DESTINATION "${APPDATA_INSTALL_DIR}")

  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.desktop.in
                 ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${TARGET}.desktop @ONLY)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${TARGET}.desktop DESTINATION "${XDG_APPS_INSTALL_DIR}")

  install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png" DESTINATION "${ICON_INSTALL_DIR}")

  install(FILES ${qm_files} DESTINATION ${TRANSLATION_INSTALL_DIR})

  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/flatpak.yml.in ${CMAKE_CURRENT_BINARY_DIR}/flatpak.xml @ONLY)

  configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/snapcraft.yaml.in ${PROJECT_SOURCE_DIR}/snapcraft.yaml @ONLY)

  # man page
  find_program(GZIP gzip)
  if(GZIP)
    configure_file(${CMAKE_SOURCE_DIR}/cmake/modules/app.1.in ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.1 @ONLY)
    add_custom_command(
      OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.1.gz
      COMMAND ${GZIP} -c ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.1 > ${TARGET}.1.gz
      COMMENT "Create the bin gz archive"
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.1)
    add_custom_target(
      man ALL
      COMMENT "Create man-file"
      DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.1.gz)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${TARGET}.1.gz DESTINATION "${MAN_INSTALL_DIR}")
  endif()
endif()

# Tests
if(OPTION_BUILD_TESTS)
  set(IDE_FOLDER "Tests")
  enable_testing()
  add_subdirectory(test)
endif()

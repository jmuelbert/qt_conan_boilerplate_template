#
# SPDX-FileCopyrightText: 2022 Project qt_conan_boilerplate_template, Jürgen Mülbert
#
# SPDX-License-Identifier: EUPL-1.2
#
#
# Options
#
# ${PROJECT_PREFIX}AS_SYSTEM_HEADERS=[true, false]
#  Exports library as system HEADERS
#  Default=false

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
    qtwidgettest
    VERSION 0.0.2
    LANGUAGES CXX
)

set(PROJECT_PREFIX QTWIDGETTEST_)

option(${PROJECT_PREFIX}AS_SYSTEM_HEADERS "Exports library as system HEADERS" OFF)

list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")

#Generate version - header
configure_file(version.h.in ${CMAKE_CURRENT_BINARY_DIR}/include/${PROJECT_NAME}/${PROJECT_NAME}-version.h @ONLY)

#
# SOURCES
#

set(INCLUDE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/include/${PROJECT_NAME}")
set(SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/source")

set(HEADERS ${INCLUDE_PATH}/main.h ${INCLUDE_PATH}/mainwindow.h)

set(SOURCES ${SOURCE_PATH}/main.cpp ${SOURCE_PATH}/mainwindow.cpp ${SOURCE_PATH}/mainwindow.ui)

set(TS_FILES translations/QtWidgetTest_de_DE.ts)

source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${SOURCES})

find_package(fmt CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

find_package(
    QT
    NAMES
    Qt6
    Qt5
    REQUIRED
    COMPONENTS Widgets LinguistTools
)

find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS Widgets LinguistTools)

#
# Create app
#

if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    if(${QT_VERSION_MINOR} GREATER_EQUAL 3)
        qt_standard_project_setup()
    else()
        set(CMAKE_AUTOMOC ON)
        set(CMAKE_AUTOUIC ON)
        include(GNUInstallDirs)
    endif()
    qt_add_executable(
        ${PROJECT_NAME}
        WIN32
        MACOSX_BUNDLE
        MANUAL_FINALIZATION
        ""
    )
    # Define PROJECT_NAME properties for Android with Qt 6 as:
    #    set_property(PROJECT_NAME ${PROJECT_NAME} APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
    #                 ${CMAKE_CURRENT_SOURCE_DIR}/android)
    # For more information, see https://doc.qt.io/qt-6/qt-add-executable.html#PROJECT_NAME-creation

    qt_add_translations(${PROJECT_NAME} TS_FILES ${TS_FILES})
    qt_add_resources(
        ${PROJECT_NAME}
        "translations"
        PREFIX
        "/i18n"
        BASE
        "${CMAKE_CURRENT_BINARY_DIR}"
        FILES
        "${qm_files}"
    )
else()
    if(ANDROID)
        add_library(${PROJECT_NAME} SHARED "")
        # Define properties for Android with Qt 5 after find_package() calls as:
        #    set(ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android")
    else()
        set(CMAKE_AUTOMOC ON)
        set(CMAKE_AUTOUIC ON)
        include(GNUInstallDirs)
        add_executable(${PROJECT_NAME} WIN32 MACOSX_BUNDLE "")
    endif()
    set(TS_FILES translations/QtWidgetTest_de_DE.ts)
    set_source_files_properties(${TS_FILES} PROPERTIES OUTPUT_LOCATION "${CMAKE_CURRENT_BINARY_DIR}/translations")
    qt5_create_translation(QM_FILES ${CMAKE_SOURCE_DIR} ${TS_FILES})

endif()

target_sources(${PROJECT_NAME} PRIVATE ${SOURCES} ${HEADERS} ${MOC_SOURCE_FILES})

# Create feature detection header
# Compilers:
#   https://cmake.org/cmake/help/v3.1/variable/CMAKE_LANG_COMPILER_ID.html#variable:CMAKE_%3CLANG%3E_COMPILER_ID
# Feature: https://cmake.org/cmake/help/v3.1/prop_gbl/CMAKE_CXX_KNOWN_FEATURES.html

# Check for availability of module; use pre-generated version if not found
if(WriterCompilerDetectionHeaderFound)
    write_compiler_detection_header(
        FILE ${feature_file} PREFIX ${PROJECT_NAME_ID}
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

# set_target_properties(
#     ${PROJECT_NAME} PROPERTIES ${DEFAULT_PROJECT_OPTIONS} INSTALL_RPATH "${LIBRARY_INSTALL_RPATH}" FOLDER
#                                "${IDE_FOLDER}"
# )

set_target_properties(${PROJECT_NAME} PROPERTIES INSTALL_RPATH "${LIBRARY_INSTALL_RPATH}" FOLDER "${IDE_FOLDER}")
#
# Include directories
#

target_include_directories(
    ${PROJECT_NAME}
    PRIVATE ${PROJECT_BINARY_DIR}/src/include ${CMAKE_CURRENT_SOURCE_DIR}/include ${CMAKE_CURRENT_BINARY_DIR}/include
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
    PUBLIC ${DEFAULT_LIBRARIES}
    INTERFACE
)

#
# Compile definitions
#

target_compile_definitions(
    ${PROJECT_NAME}
    PRIVATE
    PUBLIC $<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:${PROJECT_NAME_ID}_STATIC_DEFINE> ${DEFAULT_COMPILE_DEFINITIONS}
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
    PRIVATE fmt::fmt spdlog::spdlog Qt${QT_VERSION_MAJOR}::Widgets
    PUBLIC ${DEFAULT_LINKER_OPTIONS}
    INTERFACE
)

if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(${PROJECT_NAME})
endif()

#
# Deployment
#

if(APPLE OR WIN32)

    if(APPLE)

        set(EXECUTABLE_PATH "$<TARGET_FILE_NAME:${PROJECT_NAME}>.app")

        set_property(
            TARGET ${PROJECT_NAME} PROPERTY MACOSX_BUNDLE_INFO_PLIST
                                            ${CMAKE_SOURCE_DIR}/cmake/config/MacOSXBundleInfo.plist.in
        )

        # the MacOSX bundle display name property (CFBundleDisplayName) is not
        # currently supported by cmake, so has to be set for all PROJECT_NAMEs in this cmake
        # file
        set(MACOSX_BUNDLE_DISPLAY_NAME ${PROJECT_NAME})
        set_target_properties(
            ${PROJECT_NAME}
            PROPERTIES BUNDLE True
                       MACOSX_BUNDLE_GUI_IDENTIFIER "io.github.jmuelbert.${PROJECT_NAME}"
                       MACOSX_BUNDLE_BUNDLE_NAME "${PROJECT_NAME}"
                       MACOSX_BUNDLE_DISPLAY_NAME "${PROJECT_NAME}"
                       MACOSX_BUNDLE_INFO_STRING "${PROJECT_NAME} - A Test program"
                       MACOSX_BUNDLE_LONG_VERSION_STRING "${PROJECT_NAME} ${PROJECT_VERSION}"
                       MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
                       MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
                       MACOSX_BUNDLE_ICON_FILE "${ICONS_SOURCES}"
                       MACOSX_BUNDLE_COPYRIGHT "2022 Jürgen Mülbert"
        )

        install(TARGETS ${PROJECT_NAME} BUNDLE DESTINATION . COMPONENT Runtime)

        install(FILES ${qm_files} DESTINATION ${TRANSLATION_INSTALL_DIR})

        # install(
        #     TARGETS ${PROJECT_NAME}
        #     DESTINATION RESOURCE
        #     "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png"
        # )

        configure_file(
            ${CMAKE_SOURCE_DIR}/cmake/config/package_dmg.json.in ${CMAKE_CURRENT_BINARY_DIR}/package_dmg.json @ONLY
        )

    elseif(WIN32)
        set(EXECUTABLE_PATH "\${QT_DEPLOY_BIN_DIR}/$<TARGET_FILE_NAME:${PROJECT_NAME}>")
        configure_file(${CMAKE_SOURCE_DIR}/cmake/config/app.rc.in ${PROJECT_BINARY_DIR}/app.rc @ONLY)

        install(TARGETS ${PROJECT_NAME} ${INSTALL_PROJECT_NAMES_DEFAULT_ARGS})

        install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png"
                DESTINATION "${CMAKE_INSTALL_DATADIR}"
        )

        install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-80.png" DESTINATION "${CMAKE_INSTALL_BINDIR}")

        install(FILES ${qm_files} DESTINATION "${CMAKE_INSTALL_BINDIR}/Translations")
    endif()
    # The following script must only be executed at install time
    set(DEPLOY_SCRIPT "${CMAKE_CURRENT_BINARY_DIR}/deploy_${PROJECT_NAME}.cmake")

    file(
        GENERATE
        OUTPUT ${DEPLOY_SCRIPT}
        CONTENT
            "
# Including the file pointed to by QT_DEPLOY_SUPPORT ensures the generated
# deployment script has access to qt_deploy_runtime_dependencies()
include(\"${QT_DEPLOY_SUPPORT}\")
qt_deploy_runtime_dependencies(
    EXECUTABLE \"${EXECUTABLE_PATH}\"
    # ADDITIONAL_EXECUTABLES \"${helper_app_path}\"
    GENERATE_QT_CONF
    # VERBOSE
)"
    )

    # Omitting RUNTIME DESTINATION will install a non-bundle PROJECT_NAME to CMAKE_INSTALL_BINDIR,
    # which coincides with the default value of QT_DEPLOY_BIN_DIR used above, './bin'.
    # Installing macOS bundles always requires an explicit BUNDLE DESTINATION option.
    install(TARGETS ${PROJECT_NAME} # Install to CMAKE_INSTALL_PREFIX/bin/MyApp.exe
                    #                           and ./binHelperApp.exe
            BUNDLE DESTINATION . # Install to CMAKE_INSTALL_PREFIX/MyApp.app/Contents/MacOS/MyApp
    )

    install(SCRIPT ${DEPLOY_SCRIPT}) # Add its runtime dependencies
elseif(UNIX AND NOT APPLE)
    # appdata

    install(TARGETS ${PROJECT_NAME} ${INSTALL_PROJECT_NAMES_DEFAULT_ARGS})

    configure_file(
        ${CMAKE_SOURCE_DIR}/cmake/config/appdata.xml.in
        ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.metainfo.xml @ONLY
    )

    # APPDATA_DIR
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.metainfo.xml
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/metainfo"
    )

    configure_file(
        ${CMAKE_SOURCE_DIR}/cmake/config/app.desktop.in
        ${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.desktop @ONLY
    )
    #${XDG_APPS_INSTALL_DIR}
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/io.github.jmuelbert.${PROJECT_NAME}.desktop"
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/applications"
    )

    # icons

    install(FILES "${CMAKE_SOURCE_DIR}/assets/icons/icons8-app-symbol-16.png" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}"
            RENAME "io.github.jmuelbert.${PROJECT_NAME}.png"
    )
    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/icons8-app-symbol-16.png"
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/io.github.jmuelbert.${PROJECT_NAME}.png"
    )

    install(FILES ${qm_files} DESTINATION ${TRANSLATION_INSTALL_DIR})

    configure_file(${CMAKE_SOURCE_DIR}/cmake/config/flatpak.yml.in ${CMAKE_CURRENT_BINARY_DIR}/flatpak.xml @ONLY)

    configure_file(${CMAKE_SOURCE_DIR}/cmake/config/snapcraft.yaml.in ${PROJECT_SOURCE_DIR}/snapcraft.yaml @ONLY)

    # man page
    find_program(GZIP gzip)
    if(GZIP)
        configure_file(${CMAKE_SOURCE_DIR}/cmake/config/app.1.in ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1 @ONLY)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.1 DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/man")
    endif()
endif()

#
# Deployment (global project files)
#

#Deploy generated HEADERS
install(
    DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/${PROJECT_NAME}
    DESTINATION include
    COMPONENT dev
)

# Install cmake find script for the project
# install(
#     FILES "${CMAKE_CURRENT_SOURCE_DIR}/${PROJECT_NAME}-config.cmake"
#     DESTINATION ${CMAKE_INSTALL_BINDIR}
#     COMPONENT dev
# )

# Tests
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(test)
endif()

add_folders(apps)

find_package(fmt CONFIG)
find_package(spdlog CONFIG)
find_package(CLI11 CONFIG REQUIRED)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)
set(BUNDLE_EXTENSION .)

find_package(Qt6 COMPONENTS Core Gui Widgets REQUIRED)

# Generic test that uses conan libs
qt_add_executable(app 
  WIN32
  MANUAL_FINALIZATION
  main.cpp Window1.cpp 
  Window1.h
  Window1.ui
  res/MyApp.qrc
  )

target_link_libraries(
  app
  PUBLIC project_options project_warnings
  PRIVATE 
    CLI11::CLI11 
    fmt::fmt 
    spdlog::spdlog
    MyLib
    Qt6::Core
    Qt6::Gui
    Qt6::Widgets
    )

target_include_directories(app PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include")

if(WIN32)
  target_link_options(app PRIVATE "/entry:mainCRTStartup")
endif()

if (APPLE)
    # # Since there appear to exist problems with NOT setting the RPATH when building
    # # by enabling CMAKE_KEEP_RPATH and others, we just set the libs absolute paths
    # # to the conan lib dir.

    # function(ChangeRPath target file new)
    #     add_custom_command(TARGET App
    #             POST_BUILD COMMAND
    #             ${CMAKE_INSTALL_NAME_TOOL} -change @rpath/${file} ${new}/${file}
    #             $<TARGET_FILE:App>)
    # endfunction()

    # foreach(qt_lib IN LISTS CONAN_LIBS_QT)
    #     ChangeRPath(App lib${qt_lib}.dylib ${CONAN_LIB_DIRS_QT})
    # endforeach()
    # Destination paths below are relative to ${CMAKE_INSTALL_PREFIX}
    set(MACOSX_BUNDLE_DISPLAY_NAME "App")

    install(TARGETS app
        BUNDLE DESTINATION . COMPONENT Runtime
        RUNTIME DESTINATION ${INSTALL_RUNTIME_DIR} COMPONENT Runtime
   )

    # Note Mac specific extension .app
    set(APPS "\$ENV{DESTDIR}\${CMAKE_INSTALL_PREFIX}/${PROJECT_NAME}.app")

endif ()

qt_finalize_target(app)

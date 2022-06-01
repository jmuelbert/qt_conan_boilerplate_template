include(GNUInstallDirs)

include_directories(${CMAKE_CURRENT_BINARY_DIR})

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
  MANUAL_FINALIZATION
  ${SOURCE_FILES}
  ${HEADER_FILES}
  ${MOC_SOURCE_FILES})

add_library(MyLib::MyLib ALIAS MyLib)

target_include_directories(MyLib
    INTERFACE
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_link_libraries(MyLib PUBLIC Qt6::Core)

qt_finalize_target(MyLib)

#
# Install instructions
#
set(INSTALL_CONFIGDIR ${CMAKE_INSTALL_LIBDIR}/cmake/MyLib)


install(TARGETS MyLib
        EXPORT MyLib-Targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(FILES MyClass.h DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(EXPORT MyLib-Targets
        FILE MyLibTargets.cmake
        NAMESPACE MyLib::
        DESTINATION ${INSTALL_CONFIGDIR})

export(
  EXPORT MyLib-Targets
  FILE ${CMAKE_CURRENT_BINARY_DIR}/MyLibTargets.cmake
  NAMESPACE MyLib::)
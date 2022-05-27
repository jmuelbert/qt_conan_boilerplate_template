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

target_link_libraries(MyLib PUBLIC project_options project_warnings Qt6::Core)

qt_finalize_target(MyLib)

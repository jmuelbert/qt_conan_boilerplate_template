#
# Configuration for all sub-projects
#

# Generate version-header
configure_file(version.h.in ${CMAKE_CURRENT_BINARY_DIR}/include/${META_PROJECT_NAME}/${META_PROJECT_NAME}-version.h
               @ONLY)

#
# Sub-projects
#

# Libraries
set(IDE_FOLDER "lib")
add_subdirectory(lib)

# Examples
# set(IDE_FOLDER "Examples")
# add_subdirectory(examples)

# App
set(IDE_FOLDER "")
add_subdirectory(app)

#
# Deployment
#

# Deploy generated headers
install(
  DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/${META_PROJECT_NAME}
  DESTINATION include
  COMPONENT dev)

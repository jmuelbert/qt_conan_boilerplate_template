#
# Target 'pack'
#

add_custom_target(pack COMMENT "Add Pack as Build-Target")
set_target_properties(pack PROPERTIES EXCLUDE_FROM_DEFAULT_BUILD 1)

# Install additional runtime dependencies
# include(${PROJECT_SOURCE_DIR}/cmake/RuntimeDependencies.cmake)

#
# Packages
#
set(META_PROJECT_NAME "TEST")
set(META_AUTHOR_ORGANIZATION "Jürgen Mülbert")
set(META_AUTHOR_MAINTAINER "Jürgen Mülbert")
# include(packages/pack.cmake)

#
# Target 'component_install'
#

add_custom_target(
    component_install
    COMMAND make preinstall
    COMMAND ${CMAKE_COMMAND} -P ${PROJECT_SOURCE_DIR}/cmake/ComponentInstall.cmake
    WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
    COMMENT "Add Install as build target"
)

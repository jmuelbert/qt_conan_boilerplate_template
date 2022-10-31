include_guard()

# Enable coverage reporting for gcc/clang
function(enable_coverage project_name)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
        target_compile_options(${project_name} INTERFACE --coverage -O0 -g)
        target_link_libraries(${project_name} INTERFACE --coverage)
    endif()
endfunction()

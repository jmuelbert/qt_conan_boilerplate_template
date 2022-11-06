install(
    TARGETS Test1_exe
    RUNTIME COMPONENT Test1_Runtime
)

if(PROJECT_IS_TOP_LEVEL)
  include(CPack)
endif()

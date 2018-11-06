file(GLOB SOURCES "*.cc")
file(GLOB HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/*.h)

if (SOURCES)
    # this is the "object library" target: compiles the sources only once
    add_library(${ProjectName} OBJECT ${SOURCES})
    # shared libraries need PIC
    set_property(TARGET ${ProjectName} PROPERTY POSITION_INDEPENDENT_CODE 1)
endif ()

install(FILES ${HEADERS} DESTINATION ${CMAKE_INSTALL_PREFIX}/include/${PROJECT_NAME} COMPONENT devel)

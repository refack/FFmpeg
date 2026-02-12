include(sources.cmake)

find_program(SH_EXE sh REQUIRED)
set(FFVERSION_H ${CMAKE_BINARY_DIR}/libavutil/ffversion.h)

add_custom_command(
    OUTPUT ${FFVERSION_H}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/libavutil
    COMMAND ${SH_EXE} ${CMAKE_SOURCE_DIR}/ffbuild/version.sh ${CMAKE_SOURCE_DIR} ffversion.h
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/libavutil
    DEPENDS ${CMAKE_SOURCE_DIR}/ffbuild/version.sh
)

# Ensure ffversion.h is generated before compiling avutil
add_custom_target(gen_ffversion DEPENDS ${FFVERSION_H})

add_library(avutil ${LIBAVUTIL_SOURCES})
add_dependencies(avutil gen_ffversion)

# Internal build
target_compile_definitions(avutil PRIVATE HAVE_AV_CONFIG_H)

target_link_libraries(avutil
    PRIVATE
    ${CMAKE_THREAD_LIBS_INIT}
    ${LIBM}
)

if(CONFIG_ZLIB)
    target_link_libraries(avutil PRIVATE ${ZLIB_LIBRARIES})
endif()

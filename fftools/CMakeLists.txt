include(sources.cmake)

# Find Python3 for resource generation
find_package(Python3 REQUIRED)

function(add_resource output input varname)
    add_custom_command(
        OUTPUT ${output}
        COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/ffbuild/codegen.py file2c ${input} ${output} ${varname}
        DEPENDS ${input} ${CMAKE_SOURCE_DIR}/ffbuild/codegen.py
    )
endfunction()

# Automatically handle resources identified in sources.cmake
set(ALL_TOOL_SOURCES ${FFMPEG_SOURCES} ${FFPROBE_SOURCES} ${FFPLAY_SOURCES})
foreach(src ${ALL_TOOL_SOURCES})
    if(src MATCHES "${CMAKE_CURRENT_BINARY_DIR}/(.*)_(html|css)\\.c$")
        set(base_name ${CMAKE_MATCH_1})
        set(ext ${CMAKE_MATCH_2})
        add_resource(${src} ${CMAKE_CURRENT_SOURCE_DIR}/resources/${base_name}.${ext} ${base_name}_${ext})
    endif()
endforeach()

# Define common libraries for all tools
set(FFMPEG_COMMON_LIBS
    avdevice avfilter avformat avcodec swresample swscale avutil
    ${LIBM} ${CMAKE_THREAD_LIBS_INIT}
)

if(CONFIG_ZLIB)
    list(APPEND FFMPEG_COMMON_LIBS ${ZLIB_LIBRARIES})
endif()

# FFMPEG tool
if(CONFIG_FFMPEG)
    add_executable(ffmpeg ${FFMPEG_SOURCES})
    target_link_libraries(ffmpeg PRIVATE ${FFMPEG_COMMON_LIBS})
endif()

# FFPROBE tool
if(CONFIG_FFPROBE)
    add_executable(ffprobe ${FFPROBE_SOURCES})
    target_link_libraries(ffprobe PRIVATE ${FFMPEG_COMMON_LIBS})
endif()

# FFPLAY tool
if(CONFIG_FFPLAY)
    if(CONFIG_SDL2)
        add_executable(ffplay ${FFPLAY_SOURCES})
        target_link_libraries(ffplay PRIVATE ${FFMPEG_COMMON_LIBS} ${SDL2_LIBRARIES})
    endif()
endif()

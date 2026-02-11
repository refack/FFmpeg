set(FFMPEG_SOURCES
    ffmpeg.c
    ffmpeg_dec.c
    ffmpeg_demux.c
    ffmpeg_enc.c
    ffmpeg_filter.c
    ffmpeg_hw.c
    ffmpeg_mux.c
    ffmpeg_mux_init.c
    ffmpeg_opt.c
    ffmpeg_sched.c
    graph/graphprint.c
    sync_queue.c
    thread_queue.c
    textformat/avtextformat.c
    textformat/tf_compact.c
    textformat/tf_default.c
    textformat/tf_flat.c
    textformat/tf_ini.c
    textformat/tf_json.c
    textformat/tf_mermaid.c
    textformat/tf_xml.c
    textformat/tw_avio.c
    textformat/tw_buffer.c
    textformat/tw_stdout.c
    cmdutils.c
    opt_common.c
    resources/resman.c
)

set(FFPROBE_SOURCES
    ffprobe.c
    textformat/avtextformat.c
    textformat/tf_compact.c
    textformat/tf_default.c
    textformat/tf_flat.c
    textformat/tf_ini.c
    textformat/tf_json.c
    textformat/tf_mermaid.c
    textformat/tf_xml.c
    textformat/tw_avio.c
    textformat/tw_buffer.c
    textformat/tw_stdout.c
    cmdutils.c
    opt_common.c
)

set(FFPLAY_SOURCES
    ffplay.c
    ffplay_renderer.c
    cmdutils.c
    opt_common.c
)

# Resources
find_package(Python3 REQUIRED)

function(add_resource output input varname)
    add_custom_command(
        OUTPUT ${output}
        COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/tools/file2c.py ${input} ${output} ${varname}
        DEPENDS ${input} ${CMAKE_SOURCE_DIR}/tools/file2c.py
    )
endfunction()

# Graph resources
add_resource(${CMAKE_CURRENT_BINARY_DIR}/graph_css.c ${CMAKE_CURRENT_SOURCE_DIR}/resources/graph.css graph_css)
add_resource(${CMAKE_CURRENT_BINARY_DIR}/graph_html.c ${CMAKE_CURRENT_SOURCE_DIR}/resources/graph.html graph_html)

list(APPEND FFMPEG_SOURCES ${CMAKE_CURRENT_BINARY_DIR}/graph_css.c ${CMAKE_CURRENT_BINARY_DIR}/graph_html.c)


if(CONFIG_FFMPEG)
    add_executable(ffmpeg ${FFMPEG_SOURCES})
    target_link_libraries(ffmpeg PRIVATE
        avdevice avfilter avformat avcodec swresample swscale avutil
        ${LIBM} ${CMAKE_THREAD_LIBS_INIT}
    )
    if(CONFIG_ZLIB)
        target_link_libraries(ffmpeg PRIVATE ${ZLIB_LIBRARIES})
    endif()
endif()

if(CONFIG_FFPROBE)
    add_executable(ffprobe ${FFPROBE_SOURCES})
    target_link_libraries(ffprobe PRIVATE
        avdevice avfilter avformat avcodec swresample swscale avutil
        ${LIBM} ${CMAKE_THREAD_LIBS_INIT}
    )
    if(CONFIG_ZLIB)
        target_link_libraries(ffprobe PRIVATE ${ZLIB_LIBRARIES})
    endif()
endif()

if(CONFIG_FFPLAY)
    if(CONFIG_SDL2)
        # SDL2 detection is done in root CMakeLists.txt
        add_executable(ffplay ${FFPLAY_SOURCES})
        target_link_libraries(ffplay PRIVATE
            avdevice avfilter avformat avcodec swresample swscale avutil
            ${SDL2_LIBRARIES}
            ${LIBM} ${CMAKE_THREAD_LIBS_INIT}
        )
    endif()
endif()

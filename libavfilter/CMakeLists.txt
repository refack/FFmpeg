include(sources.cmake)

add_library(avfilter ${LIBAVFILTER_SOURCES})

# Internal build
target_compile_definitions(avfilter PRIVATE HAVE_AV_CONFIG_H)

target_link_libraries(avfilter
    PUBLIC
    avformat
    avcodec
    swscale
    swresample
    avutil
    PRIVATE
    ${LIBM}
    ${CMAKE_THREAD_LIBS_INIT}
)

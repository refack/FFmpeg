include(sources.cmake)

add_library(avfilter ${LIBAVFILTER_SOURCES})

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

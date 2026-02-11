include(sources.cmake)

add_library(avdevice ${LIBAVDEVICE_SOURCES})

target_link_libraries(avdevice
    PUBLIC
    avfilter
    avformat
    avcodec
    swscale
    swresample
    avutil
    PRIVATE
    ${LIBM}
)

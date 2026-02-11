include(sources.cmake)

add_library(avformat ${LIBAVFORMAT_SOURCES})

target_link_libraries(avformat
    PUBLIC
    avcodec
    swresample
    avutil
    PRIVATE
    ${LIBM}
)

if(CONFIG_ZLIB)
    target_link_libraries(avformat PRIVATE ${ZLIB_LIBRARIES})
endif()

if(CONFIG_NETWORK)
    # On Windows this might need ws2_32, on Linux it's implicit usually.
endif()

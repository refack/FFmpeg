include(sources.cmake)

add_library(avformat ${LIBAVFORMAT_SOURCES})

target_include_directories(avformat PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Internal build
target_compile_definitions(avformat PRIVATE HAVE_AV_CONFIG_H)

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

if(BZIP2_FOUND)
    target_link_libraries(avformat PRIVATE ${BZIP2_LIBRARIES})
endif()

if(LIBLZMA_FOUND)
    target_link_libraries(avformat PRIVATE ${LIBLZMA_LIBRARIES})
endif()

if(CONFIG_NETWORK)
    # On Windows this might need ws2_32
endif()

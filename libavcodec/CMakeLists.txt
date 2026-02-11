include(sources.cmake)

add_library(avcodec ${LIBAVCODEC_SOURCES})

target_link_libraries(avcodec
    PUBLIC
    swresample
    avutil
    PRIVATE
    ${CMAKE_THREAD_LIBS_INIT}
    ${LIBM}
)

if(CONFIG_ZLIB)
    target_link_libraries(avcodec PRIVATE ${ZLIB_LIBRARIES})
endif()

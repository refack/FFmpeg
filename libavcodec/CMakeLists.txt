include(sources.cmake)

add_library(avcodec ${LIBAVCODEC_SOURCES})

# Add source dir to include path for internal headers (e.g. cabac_functions.h, get_bits.h)
target_include_directories(avcodec PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Internal build
target_compile_definitions(avcodec PRIVATE HAVE_AV_CONFIG_H)

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

if(LIBLZMA_FOUND)
    target_link_libraries(avcodec PRIVATE ${LIBLZMA_LIBRARIES})
endif()

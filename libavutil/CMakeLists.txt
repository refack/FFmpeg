include(sources.cmake)

add_library(avutil ${LIBAVUTIL_SOURCES})

target_link_libraries(avutil
    PRIVATE
    ${CMAKE_THREAD_LIBS_INIT}
    ${LIBM}
)

if(CONFIG_ZLIB)
    target_link_libraries(avutil PRIVATE ${ZLIB_LIBRARIES})
endif()

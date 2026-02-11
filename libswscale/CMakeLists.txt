include(sources.cmake)

add_library(swscale ${LIBSWSCALE_SOURCES})

target_link_libraries(swscale
    PUBLIC
    avutil
    PRIVATE
    ${LIBM}
)

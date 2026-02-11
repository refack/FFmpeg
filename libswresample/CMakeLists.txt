include(sources.cmake)

add_library(swresample ${LIBSWRESAMPLE_SOURCES})

target_link_libraries(swresample
    PUBLIC
    avutil
    PRIVATE
    ${LIBM}
)

include(sources.cmake)

add_library(swscale ${LIBSWSCALE_SOURCES})

# Internal build
target_compile_definitions(swscale PRIVATE HAVE_AV_CONFIG_H)

target_link_libraries(swscale
    PUBLIC
    avutil
    PRIVATE
    ${LIBM}
)

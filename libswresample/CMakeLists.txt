include(sources.cmake)

add_library(swresample ${LIBSWRESAMPLE_SOURCES})

# Internal build
target_compile_definitions(swresample PRIVATE HAVE_AV_CONFIG_H)

target_link_libraries(swresample
    PUBLIC
    avutil
    PRIVATE
    ${LIBM}
)

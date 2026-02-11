include(sources.cmake)

add_library(avdevice ${LIBAVDEVICE_SOURCES})

# Internal build
target_compile_definitions(avdevice PRIVATE HAVE_AV_CONFIG_H)

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

if(XCB_FOUND)
    # pkg_check_modules provides variables like XCB_LIBRARIES
    # But usually PkgConfig defines variable prefix
    # I used pkg_check_modules(XCB xcb)
    target_link_libraries(avdevice PRIVATE ${XCB_LIBRARIES})
    target_include_directories(avdevice PRIVATE ${XCB_INCLUDE_DIRS})
endif()

if(XCB_SHM_FOUND)
    target_link_libraries(avdevice PRIVATE ${XCB_SHM_LIBRARIES})
endif()

if(XCB_SHAPE_FOUND)
    target_link_libraries(avdevice PRIVATE ${XCB_SHAPE_LIBRARIES})
endif()

if(XCB_XFIXES_FOUND)
    target_link_libraries(avdevice PRIVATE ${XCB_XFIXES_LIBRARIES})
endif()

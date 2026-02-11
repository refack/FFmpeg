cmake_minimum_required(VERSION 3.16)
project(FFmpeg C CXX ASM)

# Include configuration generated from config.mak
include(cmake/config.cmake)

# Set global include directories
# config.h is in the root build directory (which is same as source for now)
# Sources expect includes relative to root
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

# Add definitions from config.mak
if(HAVE_PTHREADS)
    add_compile_definitions(HAVE_PTHREADS)
    set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
    find_package(Threads REQUIRED)
endif()

# Link libraries
find_library(LIBM m)
if(NOT LIBM)
    message(STATUS "Math library not found, assuming implicit")
    set(LIBM "")
endif()

if(CONFIG_ZLIB)
    find_package(ZLIB REQUIRED)
    include_directories(${ZLIB_INCLUDE_DIRS})
endif()

# Common compiler flags
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        -std=c11
        -D_ISOC11_SOURCE
        -D_FILE_OFFSET_BITS=64
        -D_LARGEFILE_SOURCE
        -D_POSIX_C_SOURCE=200112
        -D_XOPEN_SOURCE=600
        -Wall
        -Wno-deprecated-declarations
        -Wno-unused-variable
        -Wno-unused-function
        -Wno-parentheses
        -Wno-switch
        -Wno-format-zero-length
        -Wno-pointer-sign
        -Wno-unused-const-variable
        -Wno-bool-operation
        -Wno-char-subscripts
        -Wno-maybe-uninitialized
    )
endif()

# Add subdirectories
add_subdirectory(libavutil)
add_subdirectory(libswscale)
add_subdirectory(libswresample)
add_subdirectory(libavcodec)
add_subdirectory(libavformat)
add_subdirectory(libavdevice)
add_subdirectory(libavfilter)
add_subdirectory(fftools)

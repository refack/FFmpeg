cmake_minimum_required(VERSION 3.16)
project(FFmpeg C CXX ASM)

# Enable Position Independent Code (PIC)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Include configuration generated from config.mak
include(cmake/config.cmake)

include(CheckSymbolExists)
include(CheckIncludeFile)

# Set global include directories
include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)

# Apply flags from configure
# config.mak separates CPPFLAGS (defines, includes) and CFLAGS (compiler options)
string(REPLACE " " ";" CPPFLAGS_LIST "${CPPFLAGS}")
string(REPLACE " " ";" CFLAGS_LIST "${CFLAGS}")

# Add CPPFLAGS to compile options (for C and CXX)
add_compile_options(${CPPFLAGS_LIST})
add_compile_options(${CFLAGS_LIST})

# NOTE: HAVE_AV_CONFIG_H is NOT defined globally. It is defined per-library.

# Detect Pthreads
if(CONFIG_PTHREADS OR HAVE_PTHREADS)
    set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
    find_package(Threads REQUIRED)
    if(Threads_FOUND)
        add_compile_definitions(HAVE_PTHREADS=1)

        set(CMAKE_REQUIRED_LIBRARIES Threads::Threads)
        check_include_file(pthread.h HAVE_PTHREAD_H)

        check_symbol_exists(pthread_create pthread.h HAVE_PTHREAD_CREATE)
        check_symbol_exists(pthread_cancel pthread.h HAVE_PTHREAD_CANCEL)
        check_symbol_exists(pthread_join pthread.h HAVE_PTHREAD_JOIN)
        check_symbol_exists(pthread_setname_np pthread.h HAVE_PTHREAD_SETNAME_NP)
        check_symbol_exists(pthread_set_name_np pthread.h HAVE_PTHREAD_SET_NAME_NP)

        check_include_file(semaphore.h HAVE_SEMAPHORE_H)
        if(HAVE_SEMAPHORE_H)
            check_symbol_exists(sem_timedwait semaphore.h HAVE_SEM_TIMEDWAIT)
        endif()

        # Define macros if found
        foreach(VAR HAVE_PTHREAD_CREATE HAVE_PTHREAD_CANCEL HAVE_PTHREAD_JOIN HAVE_PTHREAD_SETNAME_NP HAVE_PTHREAD_SET_NAME_NP HAVE_SEM_TIMEDWAIT)
            if(${VAR})
                add_compile_definitions(${VAR}=1)
            endif()
        endforeach()

        set(CMAKE_REQUIRED_LIBRARIES) # Reset
    endif()
endif()

# Detect Math Library
find_library(LIBM m)
if(NOT LIBM)
    message(STATUS "Math library not found, assuming implicit")
    set(LIBM "")
endif()

# Detect ZLIB
if(CONFIG_ZLIB)
    find_package(ZLIB REQUIRED)
    include_directories(${ZLIB_INCLUDE_DIRS})
    add_compile_definitions(CONFIG_ZLIB=1)
endif()

# Detect SDL2
if(CONFIG_SDL2)
    find_package(PkgConfig)
    find_package(SDL2 CONFIG)

    if(NOT SDL2_FOUND AND PKG_CONFIG_FOUND)
        pkg_check_modules(SDL2 sdl2)
    endif()

    if(SDL2_FOUND)
        include_directories(${SDL2_INCLUDE_DIRS})
        add_compile_definitions(CONFIG_SDL2=1)
        link_directories(${SDL2_LIBRARY_DIRS})
        set(SDL2_LIBRARIES ${SDL2_LIBRARIES})
    else()
        message(FATAL_ERROR "SDL2 enabled but not found")
    endif()
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

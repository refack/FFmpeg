# Auto-generated platform checks
include(CheckIncludeFile)
include(CheckFunctionExists)
include(CheckSymbolExists)
include(CheckTypeSize)

macro(ff_check_include_file header var)
    check_include_file(${header} ${var})
    if(${var})
        add_compile_definitions(${var}=1)
    endif()
endmacro()

macro(ff_check_function_exists func var)
    check_function_exists(${func} ${var})
    if(${var})
        add_compile_definitions(${var}=1)
    endif()
endmacro()

macro(ff_check_type_size type var)
    check_type_size(${type} ${var})
    if(${var})
        add_compile_definitions(${var}=1)
    endif()
endmacro()

ff_check_include_file(asm/hwprobe.h HAVE_ASM_HWPROBE_H)


ff_check_include_file(sys/hwprobe.h HAVE_SYS_HWPROBE_H)


ff_check_include_file(dispatch/dispatch.h HAVE_DISPATCH_DISPATCH_H)


ff_check_include_file(arpa/inet.h HAVE_ARPA_INET_H)


ff_check_include_file(winsock2.h HAVE_WINSOCK2_H)


ff_check_include_file(direct.h HAVE_DIRECT_H)


ff_check_include_file(dirent.h HAVE_DIRENT_H)


ff_check_include_file(dxgidebug.h HAVE_DXGIDEBUG_H)


ff_check_include_file(dxva.h HAVE_DXVA_H)


ff_check_include_file(dxva2api.h HAVE_DXVA2API_H)


ff_check_include_file(io.h HAVE_IO_H)


ff_check_include_file(linux/dma-buf.h HAVE_LINUX_DMA_BUF_H)


ff_check_include_file(linux/perf_event.h HAVE_LINUX_PERF_EVENT_H)


ff_check_include_file(malloc.h HAVE_MALLOC_H)


ff_check_include_file(mftransform.h HAVE_MFTRANSFORM_H)


ff_check_include_file(net/udplite.h HAVE_NET_UDPLITE_H)


ff_check_include_file(poll.h HAVE_POLL_H)


ff_check_include_file(pthread_np.h HAVE_PTHREAD_NP_H)


ff_check_include_file(sys/param.h HAVE_SYS_PARAM_H)


ff_check_include_file(sys/resource.h HAVE_SYS_RESOURCE_H)


ff_check_include_file(sys/select.h HAVE_SYS_SELECT_H)


ff_check_include_file(sys/time.h HAVE_SYS_TIME_H)


ff_check_include_file(sys/un.h HAVE_SYS_UN_H)


ff_check_include_file(termios.h HAVE_TERMIOS_H)


ff_check_include_file(unistd.h HAVE_UNISTD_H)


ff_check_include_file(valgrind/valgrind.h HAVE_VALGRIND_VALGRIND_H)


ff_check_include_file(windows.h HAVE_WINDOWS_H)


ff_check_include_file(asm/types.h HAVE_ASM_TYPES_H)


ff_check_include_file(jni.h HAVE_JNI_H)


ff_check_include_file(linux/fb.h HAVE_LINUX_FB_H)


ff_check_include_file(linux/videodev2.h HAVE_LINUX_VIDEODEV2_H)


ff_check_include_file(sys/videoio.h HAVE_SYS_VIDEOIO_H)


ff_check_function_exists(getaddrinfo HAVE_GETADDRINFO)


ff_check_function_exists(inet_aton HAVE_INET_ATON)


ff_check_function_exists(closesocket HAVE_CLOSESOCKET)




ff_check_function_exists(access HAVE_ACCESS)


ff_check_function_exists(fcntl HAVE_FCNTL)


ff_check_function_exists(fork HAVE_FORK)


ff_check_function_exists(gethrtime HAVE_GETHRTIME)


ff_check_function_exists(getopt HAVE_GETOPT)


ff_check_function_exists(getrusage HAVE_GETRUSAGE)


ff_check_function_exists(gettimeofday HAVE_GETTIMEOFDAY)


ff_check_function_exists(isatty HAVE_ISATTY)


ff_check_function_exists(mkstemp HAVE_MKSTEMP)


ff_check_function_exists(mmap HAVE_MMAP)


ff_check_function_exists(mprotect HAVE_MPROTECT)


ff_check_function_exists(sched_getaffinity HAVE_SCHED_GETAFFINITY)


ff_check_function_exists(setrlimit HAVE_SETRLIMIT)


ff_check_function_exists(strerror_r HAVE_STRERROR_R)


ff_check_function_exists(sysconf HAVE_SYSCONF)


ff_check_function_exists(sysctl HAVE_SYSCTL)


ff_check_function_exists(tempnam HAVE_TEMPNAM)


ff_check_function_exists(usleep HAVE_USLEEP)


ff_check_function_exists(pthread_join HAVE_PTHREAD_JOIN)


ff_check_function_exists(pthread_cancel HAVE_PTHREAD_CANCEL)


ff_check_function_exists(SecIdentityCreate HAVE_SECIDENTITYCREATE)


ff_check_function_exists(SecItemImport HAVE_SECITEMIMPORT)


set(CMAKE_EXTRA_INCLUDE_FILES netdb.h)
ff_check_type_size("struct addrinfo" HAVE_STRUCT_ADDRINFO)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES netinet/in.h)
ff_check_type_size("struct group_source_req" HAVE_STRUCT_GROUP_SOURCE_REQ)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES netinet/in.h)
ff_check_type_size("struct ip_mreq_source" HAVE_STRUCT_IP_MREQ_SOURCE)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES netinet/in.h)
ff_check_type_size("struct ipv6_mreq" HAVE_STRUCT_IPV6_MREQ)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES poll.h)
ff_check_type_size("struct pollfd" HAVE_STRUCT_POLLFD)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES netinet/sctp.h)
ff_check_type_size("struct sctp_event_subscribe" HAVE_STRUCT_SCTP_EVENT_SUBSCRIBE)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES netinet/in.h)
ff_check_type_size("struct sockaddr_in6" HAVE_STRUCT_SOCKADDR_IN6)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES sys/types.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES sys/types.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ws2tcpip.h)
ff_check_type_size("socklen_t" HAVE_SOCKLEN_T)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ws2tcpip.h)
ff_check_type_size("struct addrinfo" HAVE_STRUCT_ADDRINFO)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ws2tcpip.h)
ff_check_type_size("struct group_source_req" HAVE_STRUCT_GROUP_SOURCE_REQ)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ws2tcpip.h)
ff_check_type_size("struct ip_mreq_source" HAVE_STRUCT_IP_MREQ_SOURCE)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ws2tcpip.h)
ff_check_type_size("struct ipv6_mreq" HAVE_STRUCT_IPV6_MREQ)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES winsock2.h)
ff_check_type_size("struct pollfd" HAVE_STRUCT_POLLFD)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ws2tcpip.h)
ff_check_type_size("struct sockaddr_in6" HAVE_STRUCT_SOCKADDR_IN6)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ws2tcpip.h)
ff_check_type_size("struct sockaddr_storage" HAVE_STRUCT_SOCKADDR_STORAGE)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES AudioToolbox/AudioToolbox.h)
ff_check_type_size("AudioObjectPropertyAddress" HAVE_AUDIOOBJECTPROPERTYADDRESS)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
ff_check_type_size("DPI_AWARENESS_CONTEXT" HAVE_DPI_AWARENESS_CONTEXT)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES d3d9.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES vdpau/vdpau.h)
ff_check_type_size("VdpPictureInfoHEVC" HAVE_VDPPICTUREINFOHEVC)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES vdpau/vdpau.h)
ff_check_type_size("VdpPictureInfoVP9" HAVE_VDPPICTUREINFOVP9)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES vdpau/vdpau.h)
ff_check_type_size("VdpPictureInfoAV1" HAVE_VDPPICTUREINFOAV1)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
ff_check_type_size("CONDITION_VARIABLE" HAVE_CONDITION_VARIABLE)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES windows.h)
ff_check_type_size("INIT_ONCE" HAVE_INIT_ONCE)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES vpl/mfxdefs.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES dshow.h)
ff_check_type_size("IBaseFilter" HAVE_IBASEFILTER)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES va/va.h)
set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES CL/cl_intel.h)
ff_check_type_size("clCreateImageFromFdINTEL_fn" HAVE_CLCREATEIMAGEFROMFDINTEL_FN)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES CL/cl_va_api_media_sharing_intel.h)
ff_check_type_size("clCreateFromVA_APIMediaSurfaceINTEL_fn" HAVE_CLCREATEFROMVA_APIMEDIASURFACEINTEL_FN)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES CL/cl_dx9_media_sharing.h)
ff_check_type_size("cl_dx9_surface_info_khr" HAVE_CL_DX9_SURFACE_INFO_KHR)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES CL/cl_d3d11.h)
ff_check_type_size("clGetDeviceIDsFromD3D11KHR_fn" HAVE_CLGETDEVICEIDSFROMD3D11KHR_FN)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ffnvcodec/nvEncodeAPI.h)
ff_check_type_size("NV_ENC_PIC_PARAMS_AV1" HAVE_NV_ENC_PIC_PARAMS_AV1)

set(CMAKE_EXTRA_INCLUDE_FILES)
set(CMAKE_EXTRA_INCLUDE_FILES ffnvcodec/dynlink_cuda.h)
set(CMAKE_EXTRA_INCLUDE_FILES)

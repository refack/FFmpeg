# Progress indicator
# Removed variable: current_check=0 (2026-02-17) - replaced by autoconf-style progress lines.
progress_msg_list=
progress_msg_count=0
progress(){
    [ "$quiet" = "yes" ] && return
    [ -n "$progress_msg_list" ] && return
    progress_msg_list=$1
    progress_msg_count=1
}

progress_parts(){
    [ "$quiet" = "yes" ] && return
    label=$1
    shift
    progress_msg_list=
    progress_msg_count=0
    for part in "$@"; do
        progress_msg_list="${progress_msg_list}${progress_msg_list:+
}${label} ${part}"
        progress_msg_count=$((progress_msg_count + 1))
    done
}

progress_clear(){
    progress_msg_list=
    progress_msg_count=0
}

progress_result(){
    [ "$quiet" = "yes" ] && return
    [ -z "$progress_msg_list" ] && return
    result=$1
    while IFS= read -r progress_line; do
        [ -n "$progress_line" ] && printf 'checking %s... %s\n' "$progress_line" "$result" >&2
    done <<EOF
$progress_msg_list
EOF
    progress_clear
}

phase(){
    [ "$quiet" = "yes" ] && return
    progress_clear
    printf '\n%s\n' "$1" >&2
}


try_exec(){
    echo "Trying shell $1"
    type "$1" > /dev/null 2>&1 && exec "$@"
}

show_help(){
    cat <<EOF
Usage: configure [options]
Options: [defaults in brackets after descriptions]

Help options:
  --help                   print this message
  --quiet                  Suppress showing informative output
  --list-decoders          show all available decoders
  --list-encoders          show all available encoders
  --list-hwaccels          show all available hardware accelerators
  --list-demuxers          show all available demuxers
  --list-muxers            show all available muxers
  --list-parsers           show all available parsers
  --list-protocols         show all available protocols
  --list-bsfs              show all available bitstream filters
  --list-indevs            show all available input devices
  --list-outdevs           show all available output devices
  --list-filters           show all available filters

Standard options:
  --logfile=FILE           log tests and output to FILE [ffbuild/config.log]
  --disable-logging        do not log configure debug information
  --fatal-warnings         fail if any configure warning is generated
  --prefix=PREFIX          install in PREFIX [$prefix_default]
  --bindir=DIR             install binaries in DIR [PREFIX/bin]
  --datadir=DIR            install data files in DIR [PREFIX/share/ffmpeg]
  --docdir=DIR             install documentation in DIR [PREFIX/share/doc/ffmpeg]
  --libdir=DIR             install libs in DIR [PREFIX/lib]
  --shlibdir=DIR           install shared libs in DIR [LIBDIR]
  --incdir=DIR             install includes in DIR [PREFIX/include]
  --mandir=DIR             install man page in DIR [PREFIX/share/man]
  --pkgconfigdir=DIR       install pkg-config files in DIR [LIBDIR/pkgconfig]
  --enable-rpath           use rpath to allow installing libraries in paths
                           not part of the dynamic linker search path
                           use rpath when linking programs (USE WITH CARE)
  --install-name-dir=DIR   Darwin directory name for installed targets

Licensing options:
  --enable-gpl             allow use of GPL code, the resulting libs
                           and binaries will be under GPL [no]
  --enable-version3        upgrade (L)GPL to version 3 [no]
  --enable-nonfree         allow use of nonfree code, the resulting libs
                           and binaries will be unredistributable [no]

Configuration options:
  --disable-static         do not build static libraries [no]
  --enable-shared          build shared libraries [no]
  --enable-small           optimize for size instead of speed
  --disable-runtime-cpudetect disable detecting CPU capabilities at runtime (smaller binary)
  --enable-gray            enable full grayscale support (slower color)
  --disable-swscale-alpha  disable alpha channel support in swscale
  --disable-unstable       disable building optional unstable / experimental code
  --disable-all            disable building components, libraries and programs
  --disable-autodetect     disable automatically detected external libraries [no]

Program options:
  --disable-programs       do not build command line programs
  --disable-ffmpeg         disable ffmpeg build
  --disable-ffplay         disable ffplay build
  --disable-ffprobe        disable ffprobe build

Documentation options:
  --disable-doc            do not build documentation
  --disable-htmlpages      do not build HTML documentation pages
  --disable-manpages       do not build man documentation pages
  --disable-podpages       do not build POD documentation pages
  --disable-txtpages       do not build text documentation pages

Component options:
  --disable-avdevice       disable libavdevice build
  --disable-avcodec        disable libavcodec build
  --disable-avformat       disable libavformat build
  --disable-swresample     disable libswresample build
  --disable-swscale        disable libswscale build
  --disable-avfilter       disable libavfilter build
  --disable-pthreads       disable pthreads [autodetect]
  --disable-w32threads     disable Win32 threads [autodetect]
  --disable-os2threads     disable OS/2 threads [autodetect]
  --disable-network        disable network support [no]
  --disable-dwt            disable DWT code
  --disable-error-resilience disable error resilience code
  --disable-lsp            disable LSP code
  --disable-faan           disable floating point AAN (I)DCT code
  --disable-iamf           disable support for Immersive Audio Model
  --disable-pixelutils     disable pixel utils in libavutil

Individual component options:
  --disable-everything     disable all components listed below
  --disable-encoder=NAME   disable encoder NAME
  --enable-encoder=NAME    enable encoder NAME
  --disable-encoders       disable all encoders
  --disable-decoder=NAME   disable decoder NAME
  --enable-decoder=NAME    enable decoder NAME
  --disable-decoders       disable all decoders
  --disable-hwaccel=NAME   disable hwaccel NAME
  --enable-hwaccel=NAME    enable hwaccel NAME
  --disable-hwaccels       disable all hwaccels
  --disable-muxer=NAME     disable muxer NAME
  --enable-muxer=NAME      enable muxer NAME
  --disable-muxers         disable all muxers
  --disable-demuxer=NAME   disable demuxer NAME
  --enable-demuxer=NAME    enable demuxer NAME
  --disable-demuxers       disable all demuxers
  --enable-parser=NAME     enable parser NAME
  --disable-parser=NAME    disable parser NAME
  --disable-parsers        disable all parsers
  --enable-bsf=NAME        enable bitstream filter NAME
  --disable-bsf=NAME       disable bitstream filter NAME
  --disable-bsfs           disable all bitstream filters
  --enable-protocol=NAME   enable protocol NAME
  --disable-protocol=NAME  disable protocol NAME
  --disable-protocols      disable all protocols
  --enable-indev=NAME      enable input device NAME
  --disable-indev=NAME     disable input device NAME
  --disable-indevs         disable input devices
  --enable-outdev=NAME     enable output device NAME
  --disable-outdev=NAME    disable output device NAME
  --disable-outdevs        disable output devices
  --disable-devices        disable all devices
  --enable-filter=NAME     enable filter NAME
  --disable-filter=NAME    disable filter NAME
  --disable-filters        disable all filters

External library support:

  Using any of the following switches will allow FFmpeg to link to the
  corresponding external library. All the components depending on that library
  will become enabled, if all their other dependencies are met and they are not
  explicitly disabled. E.g. --enable-libopus will enable linking to
  libopus and allow the libopus encoder to be built, unless it is
  specifically disabled with --disable-encoder=libopus.

  Note that only the system libraries are auto-detected. All the other external
  libraries must be explicitly enabled.

  Also note that the following help text describes the purpose of the libraries
  themselves, not all their features will necessarily be usable by FFmpeg.

  --disable-alsa           disable ALSA support [autodetect]
  --disable-appkit         disable Apple AppKit framework [autodetect]
  --disable-avfoundation   disable Apple AVFoundation framework [autodetect]
  --enable-avisynth        enable reading of AviSynth script files [no]
  --disable-bzlib          disable bzlib [autodetect]
  --enable-cairo           enable cairo [no]
  --disable-coreimage      disable Apple CoreImage framework [autodetect]
  --enable-chromaprint     enable audio fingerprinting with chromaprint [no]
  --enable-frei0r          enable frei0r video filtering [no]
  --enable-gcrypt          enable gcrypt, needed for rtmp(t)e support
                           if openssl, librtmp or gmp is not used [no]
  --enable-gmp             enable gmp, needed for rtmp(t)e support
                           if openssl or librtmp is not used [no]
  --enable-gnutls          enable gnutls, needed for https support
                           if openssl, libtls or mbedtls is not used [no]
  --disable-iconv          disable iconv [autodetect]
  --enable-jni             enable JNI support [no]
  --enable-ladspa          enable LADSPA audio filtering [no]
  --enable-lcms2           enable ICC profile support via LittleCMS 2 [no]
  --enable-libaom          enable AV1 video encoding/decoding via libaom [no]
  --enable-libaribb24      enable ARIB text and caption decoding via libaribb24 [no]
  --enable-libaribcaption  enable ARIB text and caption decoding via libaribcaption [no]
  --enable-libass          enable libass subtitles rendering,
                           needed for subtitles and ass filter [no]
  --enable-libbluray       enable BluRay reading using libbluray [no]
  --enable-libbs2b         enable bs2b DSP library [no]
  --enable-libcaca         enable textual display using libcaca [no]
  --enable-libcelt         enable CELT decoding via libcelt [no]
  --enable-libcdio         enable audio CD grabbing with libcdio [no]
  --enable-libcodec2       enable codec2 en/decoding using libcodec2 [no]
  --enable-libdav1d        enable AV1 decoding via libdav1d [no]
  --enable-libdavs2        enable AVS2 decoding via libdavs2 [no]
  --enable-libdc1394       enable IIDC-1394 grabbing using libdc1394
                           and libraw1394 [no]
  --enable-libdvdnav       enable libdvdnav, needed for DVD demuxing [no]
  --enable-libdvdread      enable libdvdread, needed for DVD demuxing [no]
  --enable-libfdk-aac      enable AAC de/encoding via libfdk-aac [no]
  --enable-libflite        enable flite (voice synthesis) support via libflite [no]
  --enable-libfontconfig   enable libfontconfig, useful for drawtext filter [no]
  --enable-libfreetype     enable libfreetype, needed for drawtext filter [no]
  --enable-libfribidi      enable libfribidi, improves drawtext filter [no]
  --enable-libharfbuzz     enable libharfbuzz, needed for drawtext filter [no]
  --enable-libglslang      enable runtime GLSL->SPIRV compilation via libglslang [no]
  --enable-libgme          enable Game Music Emu via libgme [no]
  --enable-libgsm          enable GSM de/encoding via libgsm [no]
  --enable-libiec61883     enable iec61883 via libiec61883 [no]
  --enable-libilbc         enable iLBC de/encoding via libilbc [no]
  --enable-libjack         enable JACK audio sound server [no]
  --enable-libjxl          enable JPEG XL de/encoding via libjxl [no]
  --enable-libklvanc       enable Kernel Labs VANC processing [no]
  --enable-libkvazaar      enable HEVC encoding via libkvazaar [no]
  --enable-liblc3          enable LC3 de/encoding via liblc3 [no]
  --enable-liblcevc-dec    enable LCEVC decoding via liblcevc-dec [no]
  --enable-liblensfun      enable lensfun lens correction [no]
  --enable-libmodplug      enable ModPlug via libmodplug [no]
  --enable-libmp3lame      enable MP3 encoding via libmp3lame [no]
  --enable-libmpeghdec     enable MPEG-H 3DA decoding via libmpeghdec [no]
  --enable-liboapv         enable APV encoding via liboapv [no]
  --enable-libopencore-amrnb enable AMR-NB de/encoding via libopencore-amrnb [no]
  --enable-libopencore-amrwb enable AMR-WB decoding via libopencore-amrwb [no]
  --enable-libopencv       enable video filtering via libopencv [no]
  --enable-libopenh264     enable H.264 encoding via OpenH264 [no]
  --enable-libopenjpeg     enable JPEG 2000 encoding via OpenJPEG [no]
  --enable-libopenmpt      enable decoding tracked files via libopenmpt [no]
  --enable-libopencolorio  enable color management via OpenColorIO [no]
  --enable-libopenvino     enable OpenVINO as a DNN module backend
                           for DNN based filters like dnn_processing [no]
  --enable-libopus         enable Opus de/encoding via libopus [no]
  --enable-libplacebo      enable libplacebo library [no]
  --enable-libpulse        enable Pulseaudio input via libpulse [no]
  --enable-libqrencode     enable QR encode generation via libqrencode [no]
  --enable-libquirc        enable QR decoding via libquirc [no]
  --enable-librabbitmq     enable RabbitMQ library [no]
  --enable-librav1e        enable AV1 encoding via rav1e [no]
  --enable-librist         enable RIST via librist [no]
  --enable-librsvg         enable SVG rasterization via librsvg [no]
  --enable-librubberband   enable rubberband needed for rubberband filter [no]
  --enable-librtmp         enable RTMP[E] support via librtmp [no]
  --enable-libshaderc      enable runtime GLSL->SPIRV compilation via libshaderc [no]
  --enable-libshine        enable fixed-point MP3 encoding via libshine [no]
  --enable-libsmbclient    enable Samba protocol via libsmbclient [no]
  --enable-libsnappy       enable Snappy compression, needed for hap encoding [no]
  --enable-libsoxr         enable Include libsoxr resampling [no]
  --enable-libspeex        enable Speex de/encoding via libspeex [no]
  --enable-libsrt          enable Haivision SRT protocol via libsrt [no]
  --enable-libssh          enable SFTP protocol via libssh [no]
  --enable-libsvtav1       enable AV1 encoding via SVT [no]
  --enable-libsvtjpegxs    enable JPEGXS encoding/decoding via SVT [no]
  --enable-libtensorflow   enable TensorFlow as a DNN module backend
                           for DNN based filters like sr [no]
  --enable-libtesseract    enable Tesseract, needed for ocr filter [no]
  --enable-libtheora       enable Theora encoding via libtheora [no]
  --enable-libtls          enable LibreSSL (via libtls), needed for https support
                           if openssl, gnutls or mbedtls is not used [no]
  --enable-libtorch        enable Torch as one DNN backend [no]
  --enable-libtwolame      enable MP2 encoding via libtwolame [no]
  --enable-libuavs3d       enable AVS3 decoding via libuavs3d [no]
  --enable-libv4l2         enable libv4l2/v4l-utils [no]
  --enable-libvidstab      enable video stabilization using vid.stab [no]
  --enable-libvmaf         enable vmaf filter via libvmaf [no]
  --enable-libvo-amrwbenc  enable AMR-WB encoding via libvo-amrwbenc [no]
  --enable-libvorbis       enable Vorbis en/decoding via libvorbis,
                           native implementation exists [no]
  --enable-libvpx          enable VP8 and VP9 de/encoding via libvpx [no]
  --enable-libvvenc        enable H.266/VVC encoding via vvenc [no]
  --enable-libwebp         enable WebP encoding via libwebp [no]
  --enable-libx264         enable H.264 encoding via x264 [no]
  --enable-libx265         enable HEVC encoding via x265 [no]
  --enable-libxeve         enable EVC encoding via libxeve [no]
  --enable-libxeveb        enable EVC encoding via libxeve (Base profile) [no]
  --enable-libxevd         enable EVC decoding via libxevd [no]
  --enable-libxevdb        enable EVC decoding via libxevd (Base profile) [no]
  --enable-libxavs         enable AVS encoding via xavs [no]
  --enable-libxavs2        enable AVS2 encoding via xavs2 [no]
  --enable-libxcb          enable X11 grabbing using XCB [autodetect]
  --enable-libxcb-shm      enable X11 grabbing shm communication [autodetect]
  --enable-libxcb-xfixes   enable X11 grabbing mouse rendering [autodetect]
  --enable-libxcb-shape    enable X11 grabbing shape rendering [autodetect]
  --enable-libxvid         enable Xvid encoding via xvidcore,
                           native MPEG-4/Xvid encoder exists [no]
  --enable-libxml2         enable XML parsing using the C library libxml2, needed
                           for dash and imf demuxing support [no]
  --enable-libzimg         enable z.lib, needed for zscale filter [no]
  --enable-libzmq          enable message passing via libzmq [no]
  --enable-libzvbi         enable teletext support via libzvbi [no]
  --enable-lv2             enable LV2 audio filtering [no]
  --disable-lzma           disable lzma [autodetect]
  --enable-decklink        enable Blackmagic DeckLink I/O support [no]
  --enable-mbedtls         enable mbedTLS, needed for https support
                           if openssl, gnutls or libtls is not used [no]
  --enable-mediacodec      enable Android MediaCodec support [no]
  --enable-mediafoundation enable encoding via MediaFoundation [auto]
  --disable-metal          disable Apple Metal framework [autodetect]
  --enable-libmysofa       enable libmysofa, needed for sofalizer filter [no]
  --enable-ohcodec         enable OpenHarmony Codec support [no]
  --enable-openal          enable OpenAL 1.1 capture support [no]
  --enable-opencl          enable OpenCL processing [no]
  --enable-opengl          enable OpenGL rendering [no]
  --enable-openssl         enable openssl, needed for https support
                           if gnutls, libtls or mbedtls is not used [no]
  --enable-pocketsphinx    enable PocketSphinx, needed for asr filter [no]
  --disable-sndio          disable sndio support [autodetect]
  --disable-schannel       disable SChannel SSP, needed for TLS support on
                           Windows if openssl and gnutls are not used [autodetect]
  --disable-sdl2           disable sdl2 [autodetect]
  --disable-securetransport disable Secure Transport, needed for TLS support
                           on OSX if openssl and gnutls are not used [autodetect]
  --enable-vapoursynth     enable VapourSynth demuxer [no]
  --enable-whisper         enable whisper filter [no]
  --disable-xlib           disable xlib [autodetect]
  --disable-zlib           disable zlib [autodetect]

  The following libraries provide various hardware acceleration features:
  --disable-amf            disable AMF video encoding code [autodetect]
  --disable-audiotoolbox   disable Apple AudioToolbox code [autodetect]
  --enable-cuda-nvcc       enable Nvidia CUDA compiler [no]
  --disable-cuda-llvm      disable CUDA compilation using clang [autodetect]
  --disable-cuvid          disable Nvidia CUVID support [autodetect]
  --disable-d3d11va        disable Microsoft Direct3D 11 video acceleration code [autodetect]
  --disable-d3d12va        disable Microsoft Direct3D 12 video acceleration code [autodetect]
  --disable-dxva2          disable Microsoft DirectX 9 video acceleration code [autodetect]
  --disable-ffnvcodec      disable dynamically linked Nvidia code [autodetect]
  --disable-libdrm         disable DRM code (Linux) [autodetect]
  --enable-libmfx          enable Intel MediaSDK (AKA Quick Sync Video) code via libmfx [no]
  --enable-libvpl          enable Intel oneVPL code via libvpl if libmfx is not used [no]
  --enable-libnpp          enable Nvidia Performance Primitives-based code [no]
  --enable-mmal            enable Broadcom Multi-Media Abstraction Layer (Raspberry Pi) via MMAL [no]
  --disable-nvdec          disable Nvidia video decoding acceleration (via hwaccel) [autodetect]
  --disable-nvenc          disable Nvidia video encoding code [autodetect]
  --enable-omx             enable OpenMAX IL code [no]
  --enable-omx-rpi         enable OpenMAX IL code for Raspberry Pi [no]
  --enable-rkmpp           enable Rockchip Media Process Platform code [no]
  --disable-v4l2-m2m       disable V4L2 mem2mem code [autodetect]
  --disable-vaapi          disable Video Acceleration API (mainly Unix/Intel) code [autodetect]
  --disable-vdpau          disable Nvidia Video Decode and Presentation API for Unix code [autodetect]
  --disable-videotoolbox   disable VideoToolbox code [autodetect]
  --disable-vulkan         disable Vulkan code [autodetect]
  --enable-vulkan-static   statically link to libvulkan [no]

Toolchain options:
  --arch=ARCH              select architecture [$arch]
  --cpu=CPU                select the minimum required CPU (affects
                           instruction selection, may crash on older CPUs)
  --cross-prefix=PREFIX    use PREFIX for compilation tools [$cross_prefix]
  --progs-suffix=SUFFIX    program name suffix []
  --enable-cross-compile   assume a cross-compiler is used
  --sysroot=PATH           root of cross-build tree
  --sysinclude=PATH        location of cross-build system headers
  --target-os=OS           compiler targets OS [$target_os]
  --target-exec=CMD        command to run executables on target
  --target-path=DIR        path to view of build directory on target
  --target-samples=DIR     path to samples directory on target
  --tempprefix=PATH        force fixed dir/prefix instead of mktemp for checks
  --toolchain=NAME         set tool defaults according to NAME
                           (<tool>[-sanitizer[-...]], e.g. clang-asan-ubsan
                           tools: gcc, clang, msvc, icl, gcov, llvm-cov,
                                  valgrind-memcheck, valgrind-massif, hardened
                           sanitizers: asan, fuzz, lsan, msan, tsan, ubsan)
  --nm=NM                  use nm tool NM [$nm_default]
  --ar=AR                  use archive tool AR [$ar_default]
  --as=AS                  use assembler AS [$as_default]
  --ln_s=LN_S              use symbolic link tool LN_S [$ln_s_default]
  --strip=STRIP            use strip tool STRIP [$strip_default]
  --windres=WINDRES        use windows resource compiler WINDRES [$windres_default]
  --x86asmexe=EXE          use nasm-compatible assembler EXE [$x86asmexe_default]
  --cc=CC                  use C compiler CC [$cc_default]
  --stdc=STDC              use C standard STDC [$stdc_default]
  --cxx=CXX                use C compiler CXX [$cxx_default]
  --stdcxx=STDCXX          use C standard STDCXX [$stdcxx_default]
  --objcc=OCC              use ObjC compiler OCC [$cc_default]
  --dep-cc=DEPCC           use dependency generator DEPCC [$cc_default]
  --glslc=GLSLC            use GLSL compiler GLSLC [$glslc_default]
  --nvcc=NVCC              use Nvidia CUDA compiler NVCC or clang [$nvcc_default]
  --ld=LD                  use linker LD [$ld_default]
  --metalcc=METALCC        use metal compiler METALCC [$metalcc_default]
  --metallib=METALLIB      use metal linker METALLIB [$metallib_default]
  --pkg-config=PKGCONFIG   use pkg-config tool PKGCONFIG [$pkg_config_default]
  --pkg-config-flags=FLAGS pass additional flags to pkgconf []
  --ranlib=RANLIB          use ranlib RANLIB [$ranlib_default]
  --doxygen=DOXYGEN        use DOXYGEN to generate API doc [$doxygen_default]
  --host-cc=HOSTCC         use host C compiler HOSTCC
  --host-cflags=HCFLAGS    use HCFLAGS when compiling for host
  --host-cppflags=HCPPFLAGS use HCPPFLAGS when compiling for host
  --host-ld=HOSTLD         use host linker HOSTLD
  --host-ldflags=HLDFLAGS  use HLDFLAGS when linking for host
  --host-extralibs=HLIBS   use libs HLIBS when linking for host
  --host-os=OS             compiler host OS [$target_os]
  --extra-cflags=ECFLAGS   add ECFLAGS to CFLAGS [$CFLAGS]
  --extra-cxxflags=ECFLAGS add ECFLAGS to CXXFLAGS [$CXXFLAGS]
  --extra-objcflags=FLAGS  add FLAGS to OBJCFLAGS [$OBJCFLAGS]
  --extra-ldflags=ELDFLAGS add ELDFLAGS to LDFLAGS [$LDFLAGS]
  --extra-ldexeflags=ELDFLAGS add ELDFLAGS to LDEXEFLAGS [$LDEXEFLAGS]
  --extra-ldsoflags=ELDFLAGS add ELDFLAGS to LDSOFLAGS [$LDSOFLAGS]
  --extra-libs=ELIBS       add ELIBS [$ELIBS]
  --extra-version=STRING   version string suffix []
  --optflags=OPTFLAGS      override optimization-related compiler flags
  --glslcflags=GLSLCFLAGS  extra glslc flags [$glslcflags_default]
  --nvccflags=NVCCFLAGS    override nvcc flags [$nvccflags_default]
  --build-suffix=SUFFIX    library name suffix []
  --enable-pic             build position-independent code
  --enable-thumb           compile for Thumb instruction set
  --enable-lto[=arg]       use link-time optimization
  --env="ENV=override"     override the environment variables
  --disable-response-files Don't pass the list of objects to linker in a file [autodetect]

Advanced options (experts only):
  --malloc-prefix=PREFIX   prefix malloc and related names with PREFIX
  --custom-allocator=NAME  use a supported custom allocator
  --disable-symver         disable symbol versioning
  --enable-hardcoded-tables use hardcoded tables instead of runtime generation
  --disable-safe-bitstream-reader
                           disable buffer boundary checking in bitreaders
                           (This disables some security checks and can cause undefined behavior,
                            crashes and arbitrary code execution, it may be faster, but
                            should only be used with trusted input)
  --sws-max-filter-size=N  the max filter size swscale uses [$sws_max_filter_size_default]

Optimization options (experts only):
  --disable-asm            disable all assembly optimizations
  --disable-altivec        disable AltiVec optimizations
  --disable-vsx            disable VSX optimizations
  --disable-power8         disable POWER8 optimizations
  --disable-mmx            disable MMX optimizations
  --disable-mmxext         disable MMXEXT optimizations
  --disable-sse            disable SSE optimizations
  --disable-sse2           disable SSE2 optimizations
  --disable-sse3           disable SSE3 optimizations
  --disable-ssse3          disable SSSE3 optimizations
  --disable-sse4           disable SSE4 optimizations
  --disable-sse42          disable SSE4.2 optimizations
  --disable-avx            disable AVX optimizations
  --disable-xop            disable XOP optimizations
  --disable-fma3           disable FMA3 optimizations
  --disable-fma4           disable FMA4 optimizations
  --disable-avx2           disable AVX2 optimizations
  --disable-avx512         disable AVX-512 optimizations
  --disable-avx512icl      disable AVX-512ICL optimizations
  --disable-aesni          disable AESNI optimizations
  --disable-clmul          disable CLMUL optimizations
  --disable-armv5te        disable armv5te optimizations
  --disable-armv6          disable armv6 optimizations
  --disable-armv6t2        disable armv6t2 optimizations
  --disable-vfp            disable VFP optimizations
  --disable-neon           disable NEON optimizations
  --disable-arm-crc        disable ARM/AArch64 CRC optimizations
  --disable-dotprod        disable DOTPROD optimizations
  --disable-i8mm           disable I8MM optimizations
  --disable-sve            disable SVE optimizations
  --disable-sve2           disable SVE2 optimizations
  --disable-sme            disable SME optimizations
  --disable-inline-asm     disable use of inline assembly
  --disable-x86asm         disable use of standalone x86 assembly
  --disable-mipsdsp        disable MIPS DSP ASE R1 optimizations
  --disable-mipsdspr2      disable MIPS DSP ASE R2 optimizations
  --disable-msa            disable MSA optimizations
  --disable-mipsfpu        disable floating point MIPS optimizations
  --disable-mmi            disable Loongson MMI optimizations
  --disable-lasx           disable Loongson LASX optimizations
  --disable-rvv            disable RISC-V Vector optimizations
  --disable-fast-unaligned consider unaligned accesses slow
  --disable-simd128        disable WebAssembly simd128 optimizations

Developer options (useful when working on FFmpeg itself):
  --disable-debug          disable debugging symbols
  --enable-debug=LEVEL     set the debug level [$debuglevel]
  --disable-optimizations  disable compiler optimizations
  --enable-extra-warnings  enable more compiler warnings
  --enable-preserve-temps  do not delete temporary files on exit
  --disable-stripping      disable stripping of executables and shared libraries
  --assert-level=level     0(default), 1 or 2, amount of assertion testing,
                           2 causes a slowdown at runtime.
  --enable-memory-poisoning fill heap uninitialized allocated space with arbitrary data
  --valgrind=VALGRIND      run "make fate" tests through valgrind to detect memory
                           leaks and errors, using the specified valgrind binary.
                           Cannot be combined with --target-exec
  --enable-ftrapv          Trap arithmetic overflows
  --samples=PATH           location of test samples for FATE, if not set use
                           \$FATE_SAMPLES at make invocation time.
  --enable-neon-clobber-test check NEON registers for clobbering (should be
                           used only for debugging purposes)
  --enable-xmm-clobber-test check XMM registers for clobbering (Win64-only;
                           should be used only for debugging purposes)
  --enable-random          randomly enable/disable components
  --disable-random
  --enable-random=LIST     randomly enable/disable specific components or
  --disable-random=LIST    component groups. LIST is a comma-separated list
                           of NAME[:PROB] entries where NAME is a component
                           (group) and PROB the probability associated with
                           NAME (default 0.5).
  --random-seed=VALUE      seed value for --enable/disable-random
  --disable-valgrind-backtrace do not print a backtrace under Valgrind
                           (only applies to --disable-optimizations builds)
  --enable-ossfuzz         Enable building fuzzer tool
  --libfuzzer=PATH         path to libfuzzer
  --ignore-tests=TESTS     comma-separated list (without "fate-" prefix
                           in the name) of tests whose result is ignored
  --enable-linux-perf      enable Linux Performance Monitor API
  --enable-macos-kperf     enable macOS kperf (private) API
  --disable-large-tests    disable tests that use a large amount of memory
  --disable-shader-compression don't compress shader code even when possible
  --disable-resource-compression don't compress resources even when possible
  --disable-version-tracking don't include the git/release version in the build

NOTE: Object files are built at the place where configure is launched.
EOF
  exit 0
}

log(){
    echo "$@" >> $logfile
}

log_file(){
    log BEGIN "$1"
    log_file_i=1
    while IFS= read -r log_file_line; do
        printf '%5d\t%s\n' "$log_file_i" "$log_file_line"
        log_file_i=$(($log_file_i+1))
    done < "$1" >> "$logfile"
    log END "$1"
}

warn(){
    log "WARNING: $*"
    WARNINGS="${WARNINGS}WARNING: $*\n"
}

die(){
    log "$@"
    echo "$error_color$bold_color$@$reset_color"
    cat <<EOF

If you think configure made a mistake, make sure you are using the latest
version from Git.  If the latest version fails, report the problem to the
ffmpeg-user@ffmpeg.org mailing list or IRC #ffmpeg on irc.libera.chat.
EOF
    if disabled logging; then
        cat <<EOF
Rerun configure with logging enabled (do not use --disable-logging), and
include the log this produces with your report.
EOF
    else
        cat <<EOF
Include the log file "$logfile" produced by configure as this will help
solve the problem.
EOF
    fi
    exit 1
}

toupper(){
    echo "$@" | tr abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLMNOPQRSTUVWXYZ
}

tolower(){
    echo "$@" | tr ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz
}

c_escape(){
    echo "$*" | sed 's/["\\]/\\\0/g'
}

sh_quote(){
    v=$(echo "$1" | sed "s/'/'\\\\''/g")
    test "x$v" = "x${v#*[!A-Za-z0-9_/.+-]}" || v="'$v'"
    echo "$v"
}

cleanws(){
    echo "$@" | sed 's/^ *//;s/[[:space:]][[:space:]]*/ /g;s/ *$//'
}

filter(){
    pat=$1
    shift
    for v; do
        eval "case '$v' in $pat) printf '%s ' '$v' ;; esac"
    done
}

filter_out(){
    pat=$1
    shift
    for v; do
        eval "case '$v' in $pat) ;; *) printf '%s ' '$v' ;; esac"
    done
}

map(){
    m=$1
    shift
    for v; do eval $m; done
}

add_suffix(){
    suffix=$1
    shift
    for v; do echo ${v}${suffix}; done
}

remove_suffix(){
    suffix=$1
    shift
    for v; do echo ${v%$suffix}; done
}

set_all(){
    value=$1
    shift
    for var in $*; do
        eval $var=$value
    done
}

set_weak(){
    value=$1
    shift
    for var; do
        eval : \${$var:=$value}
    done
}

sanitize_var_name(){
    echo $@ | sed 's/[^A-Za-z0-9_]/_/g'
}

set_sanitized(){
    var=$1
    shift
    eval $(sanitize_var_name "$var")='$*'
}

get_sanitized(){
    eval echo \$$(sanitize_var_name "$1")
}

pushvar(){
    for pvar in $*; do
        eval level=\${${pvar}_level:=0}
        eval ${pvar}_${level}="\$$pvar"
        eval ${pvar}_level=$(($level+1))
    done
}

popvar(){
    for pvar in $*; do
        eval level=\${${pvar}_level:-0}
        test $level = 0 && continue
        eval level=$(($level-1))
        eval $pvar="\${${pvar}_${level}}"
        eval ${pvar}_level=$level
        eval unset ${pvar}_${level}
    done
}

request(){
    for var in $*; do
        eval ${var}_requested=yes
        eval $var=
    done
}

warn_if_gets_disabled(){
    for var in $*; do
        WARN_IF_GETS_DISABLED_LIST="$WARN_IF_GETS_DISABLED_LIST $var"
    done
}

enable(){
    set_all yes $*
}

disable(){
    set_all no $*
}

disable_with_reason(){
    disable $1
    eval "${1}_disable_reason=\"$2\""
    if requested $1; then
        die "ERROR: $1 requested, but $2"
    fi
}

enable_weak(){
    set_weak yes $*
}

disable_weak(){
    set_weak no $*
}

enable_sanitized(){
    for var; do
        enable $(sanitize_var_name $var)
    done
}

disable_sanitized(){
    for var; do
        disable $(sanitize_var_name $var)
    done
}

do_enable_deep(){
    for var; do
        enabled $var && continue
        set -- $var
        eval enable_deep \$${var}_select
        var=$1
        eval enable_deep_weak \$${var}_suggest
    done
}

enable_deep(){
    do_enable_deep $*
    enable $*
}

enable_deep_weak(){
    for var; do
        disabled $var && continue
        set -- $var
        do_enable_deep $var
        var=$1
        enable_weak $var
    done
}

requested(){
    test "${1#!}" = "$1" && op="=" || op="!="
    eval test "x\$${1#!}_requested" $op "xyes"
}

enabled(){
    test "${1#!}" = "$1" && op="=" || op="!="
    eval test "x\$${1#!}" $op "xyes"
}

disabled(){
    test "${1#!}" = "$1" && op="=" || op="!="
    eval test "x\$${1#!}" $op "xno"
}

enabled_all(){
    for opt; do
        enabled $opt || return 1
    done
}

disabled_all(){
    for opt; do
        disabled $opt || return 1
    done
}

enabled_any(){
    for opt; do
        enabled $opt && return 0
    done
}

disabled_any(){
    for opt; do
        disabled $opt && return 0
    done
    return 1
}

set_default(){
    for opt; do
        eval : \${$opt:=\$${opt}_default}
    done
}

is_in(){
    value=$1
    shift
    for var in $*; do
        [ $var = $value ] && return 0
    done
    return 1
}

check_deps(){
    for cfg; do
        eval [ x\$${cfg}_checking = xdone ] && continue
        eval [ x\$${cfg}_checking = xinprogress ] && die "Circular dependency for $cfg."

        eval "
        dep_all=\$${cfg}_deps
        dep_any=\$${cfg}_deps_any
        dep_con=\$${cfg}_conflict
        dep_sel=\$${cfg}_select
        dep_sgs=\$${cfg}_suggest
        dep_ifa=\$${cfg}_if
        dep_ifn=\$${cfg}_if_any
        "

        # most of the time here $cfg has no deps - avoid costly no-op work
        if [ "$dep_all$dep_any$dep_con$dep_sel$dep_sgs$dep_ifa$dep_ifn" ]; then
            eval ${cfg}_checking=inprogress

            set -- $cfg "$dep_all" "$dep_any" "$dep_con" "$dep_sel" "$dep_sgs" "$dep_ifa" "$dep_ifn"
            check_deps $dep_all $dep_any $dep_con $dep_sel $dep_sgs $dep_ifa $dep_ifn
            cfg=$1; dep_all=$2; dep_any=$3; dep_con=$4; dep_sel=$5 dep_sgs=$6; dep_ifa=$7; dep_ifn=$8

            [ -n "$dep_ifa" ] && { enabled_all $dep_ifa && enable_weak $cfg; }
            [ -n "$dep_ifn" ] && { enabled_any $dep_ifn && enable_weak $cfg; }
            enabled_all  $dep_all || { disable_with_reason $cfg "not all dependencies are satisfied: $dep_all"; }
            enabled_any  $dep_any || { disable_with_reason $cfg "not any dependency is satisfied: $dep_any"; }
            disabled_all $dep_con || { disable_with_reason $cfg "some conflicting dependencies are unsatisfied: $dep_con"; }
            disabled_any $dep_sel && { disable_with_reason $cfg "some selected dependency is unsatisfied: $dep_sel"; }

            enabled $cfg && enable_deep_weak $dep_sel $dep_sgs

            for dep in $dep_all $dep_any $dep_sel $dep_sgs; do
                # filter out library deps, these do not belong in extralibs
                is_in $dep $LIBRARY_LIST && continue
                enabled $dep && eval append ${cfg}_extralibs ${dep}_extralibs
            done
        fi

        eval ${cfg}_checking=done
    done
}

print_config(){
    pfx=$1
    files=$2
    shift 2
    map 'eval echo "$v \${$v:-no}"' "$@" | python ffbuild/codegen.py print_config --prefix "$pfx" --files "$files"
}

print_enabled(){
    suf=$1
    shift
    for v; do
        enabled $v && printf "%s\n" ${v%$suf}
    done
}

append(){
    var=$1
    shift
    eval "$var=\"\$$var $*\""
}

prepend(){
    var=$1
    shift
    eval "$var=\"$* \$$var\""
}

reverse () {
    eval '
        reverse_out=
        for v in $'$1'; do
            reverse_out="$v $reverse_out"
        done
        '$1'=$reverse_out
    '
}

unique(){
    unique_out=
    eval unique_in=\$$1
    reverse unique_in
    for v in $unique_in; do
        # " $unique_out" +space such that every item is surrounded with spaces
        case " $unique_out" in *" $v "*) continue; esac  # already in list
        unique_out="$unique_out$v "
    done
    reverse unique_out
    eval $1=\$unique_out
}

resolve(){
    resolve_out=
    eval resolve_in=\$$1
    for v in $resolve_in; do
        eval 'resolve_out="$resolve_out$'$v' "'
    done
    eval $1=\$resolve_out
}

add_cppflags(){
    append CPPFLAGS "$@"
}

add_cflags(){
    append CFLAGS $($cflags_filter "$@")
}

add_cflags_headers(){
    append CFLAGS_HEADERS $($cflags_filter "$@")
}

add_cxxflags(){
    append CXXFLAGS $($cflags_filter "$@")
}

add_objcflags(){
    append OBJCFLAGS $($objcflags_filter "$@")
}

add_allcflags(){
    add_cflags "$@"
    add_cxxflags "$@"
    add_objcflags "$@"
}

add_asflags(){
    append ASFLAGS $($asflags_filter "$@")
}

add_ldflags(){
    append LDFLAGS $($ldflags_filter "$@")
}

add_ldexeflags(){
    append LDEXEFLAGS $($ldflags_filter "$@")
}

add_ldsoflags(){
    append LDSOFLAGS $($ldflags_filter "$@")
}

add_extralibs(){
    prepend extralibs $($ldflags_filter "$@")
}

add_stripflags(){
    append ASMSTRIPFLAGS "$@"
}

add_host_cppflags(){
    append host_cppflags "$@"
}

add_host_cflags(){
    append host_cflags $($host_cflags_filter "$@")
}

add_host_ldflags(){
    append host_ldflags $($host_ldflags_filter "$@")
}

add_compat(){
    append compat_objs $1
    shift
    map 'add_cppflags -D$v' "$@"
}



cc_e(){
    eval printf '%s\\n' $CC_E
}

cc_o(){
    eval printf '%s\\n' $CC_O
}

cxx_e(){
    eval printf '%s\\n' $CXX_E
}

cxx_o(){
    eval printf '%s\\n' $CXX_O
}

as_o(){
    eval printf '%s\\n' $AS_O
}

x86asm_o(){
    eval printf '%s\\n' $X86ASM_O
}

ld_o(){
    eval printf '%s\\n' $LD_O
}

hostcc_e(){
    eval printf '%s\\n' $HOSTCC_E
}

hostcc_o(){
    eval printf '%s\\n' $HOSTCC_O
}

glslc_o(){
    eval printf '%s\\n' $GLSLC_O
}

nvcc_o(){
    eval printf '%s\\n' $NVCC_O
}






















print_include(){
    hdr=$1
    test "${hdr%.h}" = "${hdr}" &&
        echo "#include $hdr"    ||
        echo "#include <$hdr>"
}



























































cp_if_changed(){
    cmp -s "$1" "$2" && { test "$quiet" != "yes" && echo "$2 is unchanged"; } && return
    mkdir -p "$(dirname $2)"
    cp -f "$1" "$2"
}

find_things_extern(){
    thing=$1
    pattern=$2
    file=$source_path/$3
    out=${4:-$thing}
    sed -n "s/^[^#]*extern.*$pattern *ff_\([^ ]*\)_$thing;/\1_$out/p" "$file" | sed 's/\r//g'
}

find_filters_extern(){
    file=$source_path/$1
    sed -n 's/^extern const FFFilter ff_[avfsinkrc]\{2,5\}_\([[:alnum:]_]\{1,\}\);/\1_filter/p' $file | sed 's/\r//g'
}

die_unknown(){
    echo "Unknown option \"$1\"."
    echo "See $0 --help for available options."
    exit 1
}

print_in_columns() {
    tr ' ' '\n' | sort | tr '\r\n' '  ' | awk -v col_width=24 -v width="$ncols" '
    {
        num_cols = width > col_width ? int(width / col_width) : 1;
        num_rows = int((NF + num_cols-1) / num_cols);
        y = x = 1;
        for (y = 1; y <= num_rows; y++) {
            i = y;
            for (x = 1; x <= num_cols; x++) {
                if (i <= NF) {
                  line = sprintf("%s%-" col_width "s", line, $i);
                }
                i = i + num_rows;
            }
            print line; line = "";
        }
    }' | sed 's/ *$//'
}

show_list() {
    suffix=_$1
    shift
    echo $* | sed s/$suffix//g | print_in_columns
    exit 0
}

rand_list(){
    IFS=', '
    set -- $*
    unset IFS
    for thing; do
        comp=${thing%:*}
        prob=${thing#$comp}
        prob=${prob#:}
        is_in ${comp} $COMPONENT_LIST && eval comp=\$$(toupper ${comp%s})_LIST
        echo "prob ${prob:-0.5}"
        printf '%s\n' $comp
    done
}

do_random(){
    action=$1
    shift
    random_seed=$(awk "BEGIN { srand($random_seed); print srand() }")
    $action $(rand_list "$@" | awk "BEGIN { srand($random_seed) } \$1 == \"prob\" { prob = \$2; next } rand() < prob { print }")
}

die_license_disabled() {
    enabled $1 || { enabled $v && die "$v is $1 and --enable-$1 is not specified."; }
}

die_license_disabled_gpl() {
    enabled $1 || { enabled $v && die "$v is incompatible with the gpl and --enable-$1 is not specified."; }
}

disable_components(){
    disabled ${1} && disable $(
        eval components="\$$(toupper ${1})_COMPONENTS"
        map 'eval echo \${$(toupper ${v%s})_LIST}' $components
    )
}

add_sanitizer_flags(){
    case "$1" in
        asan)
            add_allcflags -fsanitize=address
            add_ldflags -fsanitize=address
        ;;
        fuzz)
            add_allcflags -fsanitize=fuzzer-no-link
            add_ldflags -fsanitize=fuzzer-no-link
            : "${libfuzzer_path:=-fsanitize=fuzzer}"
        ;;
        lsan)
            add_allcflags -fsanitize=leak
            add_ldflags -fsanitize=leak
        ;;
        msan)
            add_allcflags -fsanitize=memory -fsanitize-memory-track-origins
            add_ldflags -fsanitize=memory
        ;;
        tsan)
            add_allcflags -fsanitize=thread
            add_ldflags -fsanitize=thread
        ;;
        usan|ubsan)
            add_allcflags -fsanitize=undefined
            add_ldflags -fsanitize=undefined
        ;;
        ?*)
            die "Unknown sanitizer $1"
        ;;
    esac
}

add_sanitizers(){
    IFS=-
    set -- $*
    unset IFS
    for sanitizer; do
        add_sanitizer_flags "$sanitizer"
    done
    add_allcflags -fno-omit-frame-pointer
}

exesuf() {
    case $1 in
        mingw32*|mingw64*|msys*|win32|win64|cygwin*|*-dos|freedos|opendos|os/2*|symbian|windows_nt) echo .exe ;;
    esac
}

tmpfile(){
    tmp="${FFTMPDIR}/test"$2
    (set -C; exec > $tmp) 2> /dev/null ||
        die "Unable to create temporary file in $FFTMPDIR."
    eval $1=$tmp
}

armasm_flags(){
    for flag; do
        case $flag in
            # Filter out MSVC cl.exe options from cflags that shouldn't
            # be passed to gas-preprocessor
            -M[TD]*)                                            ;;
            -guard:signret)                                     ;;
            *)                  echo $flag                      ;;
        esac
   done
}

cparser_flags(){
    for flag; do
        case $flag in
            -Wno-switch)             echo -Wno-switch-enum ;;
            -Wno-format-zero-length) ;;
            -Wdisabled-optimization) ;;
            -Wno-pointer-sign)       echo -Wno-other ;;
            *)                       echo $flag ;;
        esac
    done
}

msvc_common_flags(){
    for flag; do
        case $flag in
            # In addition to specifying certain flags under the compiler
            # specific filters, they must be specified here as well or else the
            # generic catch all at the bottom will print the original flag.
            -Wall)                ;;
            -Wextra)              ;;
            -std=c*)              echo /std:${flag#-std=};;
            # Common flags
            -fomit-frame-pointer) ;;
            -g)                   echo -Z7 ;;
            -fno-math-errno)      ;;
            -fno-common)          ;;
            -fno-signed-zeros)    ;;
            -fPIC)                ;;
            -march=*)             ;;
            -mfp16-format=*)      ;;
            -lz)                  echo zlib.lib ;;
            -lx264)               echo libx264.lib ;;
            -lstdc++)             ;;
            -l*)                  echo ${flag#-l}.lib ;;
            -LARGEADDRESSAWARE)   echo $flag ;;
            -L*) [ "$_flags_type" = "link" ] && echo -libpath:${flag#-L} ;;
            -Wl,*)                ;;
            *)                    echo $flag ;;
        esac
    done
}

msvc_flags(){
    msvc_common_flags "$@"
    for flag; do
        case $flag in
            -Wall)                echo -W3 -wd4018 -wd4146 -wd4244 -wd4305     \
                                       -wd4554 -wd4267 ;;
            -Wextra)              echo -W4 -wd4244 -wd4127 -wd4018 -wd4389     \
                                       -wd4146 -wd4057 -wd4204 -wd4706 -wd4305 \
                                       -wd4152 -wd4324 -we4013 -wd4100 -wd4214 \
                                       -wd4307 \
                                       -wd4273 -wd4554 -wd4701 -wd4703 ;;
        esac
    done
}

msvc_flags_link(){
    _flags_type=link
    msvc_flags "$@"
    unset _flags_type
}

icl_flags(){
    msvc_common_flags "$@"
    for flag; do
        case $flag in
            # Despite what Intel's documentation says -Wall, which is supported
            # on Windows, does enable remarks so disable them here.
            -Wall)                echo $flag -Qdiag-disable:remark ;;
            -std=$stdc)           echo -Qstd=$stdc ;;
            -flto*)               echo -ipo ;;
        esac
    done
}

icc_flags(){
    for flag; do
        case $flag in
            -flto*)               echo -ipo ;;
            *)                    echo $flag ;;
        esac
    done
}

suncc_flags(){
    for flag; do
        case $flag in
            -march=*|-mcpu=*)
                case "${flag#*=}" in
                    native)                   echo -xtarget=native       ;;
                    v9|niagara)               echo -xarch=sparc          ;;
                    ultrasparc)               echo -xarch=sparcvis       ;;
                    ultrasparc3|niagara2)     echo -xarch=sparcvis2      ;;
                    i586|pentium)             echo -xchip=pentium        ;;
                    i686|pentiumpro|pentium2) echo -xtarget=pentium_pro  ;;
                    pentium3*|c3-2)           echo -xtarget=pentium3     ;;
                    pentium-m)          echo -xarch=sse2 -xchip=pentium3 ;;
                    pentium4*)          echo -xtarget=pentium4           ;;
                    prescott|nocona)    echo -xarch=sse3 -xchip=pentium4 ;;
                    *-sse3)             echo -xarch=sse3                 ;;
                    core2)              echo -xarch=ssse3 -xchip=core2   ;;
                    bonnell)                   echo -xarch=ssse3         ;;
                    corei7|nehalem)            echo -xtarget=nehalem     ;;
                    westmere)                  echo -xtarget=westmere    ;;
                    silvermont)                echo -xarch=sse4_2        ;;
                    corei7-avx|sandybridge)    echo -xtarget=sandybridge ;;
                    core-avx*|ivybridge|haswell|broadwell|skylake*|knl)
                                               echo -xarch=avx           ;;
                    amdfam10|barcelona)        echo -xtarget=barcelona   ;;
                    btver1)                    echo -xarch=amdsse4a      ;;
                    btver2|bdver*|znver*)      echo -xarch=avx           ;;
                    athlon-4|athlon-[mx]p)     echo -xarch=ssea          ;;
                    k8|opteron|athlon64|athlon-fx)
                                               echo -xarch=sse2a         ;;
                    athlon*)                   echo -xarch=pentium_proa  ;;
                esac
                ;;
            -std=$stdc)           echo -x$stdc            ;;
            -fomit-frame-pointer) echo -xregs=frameptr    ;;
            -fPIC)                echo -KPIC -xcode=pic32 ;;
            -W*,*)                echo $flag              ;;
            -f*-*|-W*|-mimpure-text)                      ;;
            -shared)              echo -G                 ;;
            *)                    echo $flag              ;;
        esac
    done
}


set_ccvars(){
    eval ${1}_C=\${_cc_c-\${${1}_C}}
    eval ${1}_E=\${_cc_e-\${${1}_E}}
    eval ${1}_O=\${_cc_o-\${${1}_O}}

    if [ -n "$_depflags" ]; then
        eval "${1}_DEPFLAGS=\"\$_depflags\""
    else
        eval "${1}DEP=\"\${_DEPCMD:-\$DEPCMD}\""
        eval "${1}DEP_FLAGS=\"\${_DEPFLAGS:-\$DEPFLAGS} \${_DEP${1}FLAGS:-\$DEP${1}FLAGS}\""
        eval "DEP${1}FLAGS=\"\$_flags\""
    fi
}



enable_weak_pic() {
    disabled pic && return
    enable pic
    add_cppflags -DPIC
    case "$target_os" in
    mingw*|cygwin*|win*)
        ;;
    *)
        add_allcflags -fPIC
        add_asflags -fPIC
        ;;
    esac
}






flatten_extralibs(){
    nested_entries=
    list_name=$1
    eval list=\$${1}
    for entry in $list; do
        entry_copy=$entry
        resolve entry_copy
        flat_entries=
        for e in $entry_copy; do
            case $e in
                *_extralibs) nested_entries="$nested_entries$e ";;
                          *) flat_entries="$flat_entries$e ";;
            esac
        done
        eval $entry="\$flat_entries"
    done
    append $list_name "$nested_entries"

    resolve nested_entries
    if test -n "$(filter '*_extralibs' $nested_entries)"; then
        flatten_extralibs $list_name
    fi
}

flatten_extralibs_wrapper(){
    list_name=$1
    flatten_extralibs $list_name
    unique $list_name
    resolve $list_name
    eval $list_name=\$\(\$ldflags_filter \$$list_name\)
    eval printf \''%s'\' \""\$$list_name"\"
}

reorder_by(){
    eval rb_in=\$$1
    eval rb_ordered=\$$2

    for rb in $rb_in; do
        is_in $rb $rb_ordered || die "$rb at \$$1 is not at \$$2"
    done

    rb_out=
    for rb in $rb_ordered; do
        is_in $rb $rb_in && rb_out="$rb_out$rb "
    done
    eval $1=\$rb_out
}

expand_deps(){
    unique ${1}_deps  # required for the early break test.
    for dummy in $LIBRARY_LIST; do  # N iteratios
        eval deps=\$${1}_deps
        append ${1}_deps $(map 'eval echo \$${v}_deps' $deps)
        unique ${1}_deps
        eval '[ ${#deps} = ${#'${1}_deps'} ]' && break  # doesnt expand anymore
    done

    eval is_in $1 \$${1}_deps && die "Dependency cycle at ${1}_deps"
    reorder_by ${1}_deps LIBRARY_LIST  # linking order is expected later
}

esc(){
    echo "$*" | sed 's/%/%25/g;s/:/%3a/g'
}

export_vars(){
    for v in "$@"; do
        export "$v"
    done
}

print_enabled_components(){
    file=$1
    struct_name=$2
    name=$3
    shift 3
    enabled_items=""
    for c in $*; do
        if enabled $c; then
            case $name in
                filter_list)
                    eval c=\$full_filter_name_${c%_filter}
                ;;
                indev_list)
                    c=${c%_indev}_demuxer
                ;;
                outdev_list)
                    c=${c%_outdev}_muxer
                ;;
            esac
            enabled_items="$enabled_items $c"
        fi
    done
    python ffbuild/codegen.py print_enabled_components --file "$TMPH" --struct-name "$struct_name" --name "$name" --items "$enabled_items"
    cp_if_changed $TMPH $file
}

AVCODEC_COMPONENTS="
    bsfs
    decoders
    encoders
    hwaccels
    parsers
"

AVDEVICE_COMPONENTS="
    indevs
    outdevs
"

AVFILTER_COMPONENTS="
    filters
"

AVFORMAT_COMPONENTS="
    demuxers
    muxers
    protocols
"

COMPONENT_LIST="
    $AVCODEC_COMPONENTS
    $AVDEVICE_COMPONENTS
    $AVFILTER_COMPONENTS
    $AVFORMAT_COMPONENTS
"

EXAMPLE_LIST="
    avio_http_serve_files_example
    avio_list_dir_example
    avio_read_callback_example
    decode_audio_example
    decode_filter_audio_example
    decode_filter_video_example
    decode_video_example
    demux_decode_example
    encode_audio_example
    encode_video_example
    extract_mvs_example
    filter_audio_example
    hw_decode_example
    mux_example
    qsv_decode_example
    remux_example
    resample_audio_example
    scale_video_example
    show_metadata_example
    transcode_aac_example
    transcode_example
    vaapi_encode_example
    vaapi_transcode_example
    qsv_transcode_example
"

EXTERNAL_AUTODETECT_LIBRARY_LIST="
    alsa
    appkit
    avfoundation
    bzlib
    coreimage
    iconv
    libxcb
    libxcb_shm
    libxcb_shape
    libxcb_xfixes
    lzma
    mediafoundation
    metal
    schannel
    sdl2
    securetransport
    sndio
    xlib
    zlib
"

EXTERNAL_LIBRARY_GPL_LIST="
    avisynth
    frei0r
    libcdio
    libdavs2
    libdvdnav
    libdvdread
    librubberband
    libvidstab
    libx264
    libx265
    libxavs
    libxavs2
    libxvid
"

EXTERNAL_LIBRARY_NONFREE_LIST="
    decklink
    libfdk_aac
    libmpeghdec
"

EXTERNAL_LIBRARY_VERSION3_LIST="
    gmp
    libaribb24
    liblensfun
    libopencore_amrnb
    libopencore_amrwb
    libvo_amrwbenc
    mbedtls
    rkmpp
"

EXTERNAL_LIBRARY_GPLV3_LIST="
    libsmbclient
"

EXTERNAL_LIBRARY_LIST="
    $EXTERNAL_LIBRARY_GPL_LIST
    $EXTERNAL_LIBRARY_NONFREE_LIST
    $EXTERNAL_LIBRARY_VERSION3_LIST
    $EXTERNAL_LIBRARY_GPLV3_LIST
    cairo
    chromaprint
    gcrypt
    gnutls
    jni
    ladspa
    lcms2
    libaom
    libaribcaption
    libass
    libbluray
    libbs2b
    libcaca
    libcelt
    libcodec2
    libdav1d
    libdc1394
    libflite
    libfontconfig
    libfreetype
    libfribidi
    libharfbuzz
    libglslang
    libgme
    libgsm
    libiec61883
    libilbc
    libjack
    libjxl
    libklvanc
    libkvazaar
    liblc3
    liblcevc_dec
    libmodplug
    libmp3lame
    libmysofa
    liboapv
    libopencv
    libopencolorio
    libopenimage
    libopenh264
    libopenjpeg
    libopenmpt
    libopencolorio
    libopenvino
    libopus
    libplacebo
    libpulse
    libqrencode
    libquirc
    librabbitmq
    librav1e
    librist
    librsvg
    librtmp
    libshaderc
    libshine
    libsmbclient
    libsnappy
    libsoxr
    libspeex
    libsrt
    libssh
    libsvtav1
    libsvtjpegxs
    libtensorflow
    libtesseract
    libtheora
    libtls
    libtorch
    libtwolame
    libuavs3d
    libvo_amrwbenc
    libvorbis
    libvpx
    libvvenc
    libwebp
    libxevd
    libxevdb
    libxeve
    libxeveb
    libxml2
    libzimg
    libzmq
    libzvbi
    lv2
    mediacodec
    ohcodec
    openal
    opengl
    openssl
    pocketsphinx
    vapoursynth
    vulkan_static
    whisper
"

HWACCEL_AUTODETECT_LIBRARY_LIST="
    amf
    audiotoolbox
    cuda
    cuda_llvm
    cuvid
    d3d11va
    d3d12va
    dxva2
    ffnvcodec
    libdrm
    nvdec
    nvenc
    vaapi
    vdpau
    videotoolbox
    vulkan
    v4l2_m2m
"

EXTERNAL_LIBRARY_PROTOCOL_LIST="
    libamqp
    librist
    librtmp
"

# catchall list of things that platform_require external libs to link
EXTRALIBS_LIST="
    cpu_init
    cws2fws
"

HWACCEL_LIBRARY_NONFREE_LIST="
    cuda_nvcc
    cuda_sdk
    libnpp
"

HWACCEL_LIBRARY_LIST="
    $HWACCEL_LIBRARY_NONFREE_LIST
    libmfx
    libvpl
    mmal
    omx
    opencl
"

DOCUMENT_LIST="
    doc
    htmlpages
    manpages
    podpages
    txtpages
"

FEATURE_LIST="
    ftrapv
    gray
    hardcoded_tables
    omx_rpi
    runtime_cpudetect
    safe_bitstream_reader
    shared
    small
    static
    swscale_alpha
    unstable
"

# this list should be kept in linking order
LIBRARY_LIST="
    avdevice
    avfilter
    swscale
    avformat
    avcodec
    swresample
    avutil
"

LICENSE_LIST="
    gpl
    nonfree
    version3
"

PROGRAM_LIST="
    ffplay
    ffprobe
    ffmpeg
"

SUBSYSTEM_LIST="
    dwt
    error_resilience
    faan
    fast_unaligned
    iamf
    lsp
    pixelutils
    network
"

# COMPONENT_LIST needs to come last to ensure correct dependency checking
CONFIG_LIST="
    $DOCUMENT_LIST
    $EXAMPLE_LIST
    $EXTERNAL_LIBRARY_LIST
    $EXTERNAL_AUTODETECT_LIBRARY_LIST
    $HWACCEL_LIBRARY_LIST
    $HWACCEL_AUTODETECT_LIBRARY_LIST
    $FEATURE_LIST
    $LICENSE_LIST
    $LIBRARY_LIST
    $PROGRAM_LIST
    $SUBSYSTEM_LIST
    autodetect
    fontconfig
    large_tests
    linux_perf
    macos_kperf
    memory_poisoning
    neon_clobber_test
    ossfuzz
    pic
    shader_compression
    resource_compression
    thumb
    valgrind_backtrace
    xmm_clobber_test
    $COMPONENT_LIST
"

THREADS_LIST="
    pthreads
    os2threads
    w32threads
"

ATOMICS_LIST="
    atomics_win32
"

AUTODETECT_LIBS="
    $EXTERNAL_AUTODETECT_LIBRARY_LIST
    $HWACCEL_AUTODETECT_LIBRARY_LIST
    $THREADS_LIST
"

ARCH_LIST="
    aarch64
    arm
    ia64
    loongarch
    loongarch32
    loongarch64
    m68k
    mips
    mips64
    parisc
    ppc
    ppc64
    riscv
    s390
    sparc
    sparc64
    tilegx
    tilepro
    wasm
    x86
    x86_32
    x86_64
"

ARCH_EXT_LIST_ARM="
    armv5te
    armv6
    armv6t2
    armv8
    arm_crc
    dotprod
    i8mm
    neon
    vfp
    vfpv3
    setend
    sve
    sve2
    sme
"

ARCH_EXT_LIST_MIPS="
    mipsfpu
    mips32r2
    mips32r5
    mips64r2
    mips32r6
    mips64r6
    mipsdsp
    mipsdspr2
    msa
"

ARCH_EXT_LIST_LOONGSON="
    loongson2
    loongson3
    mmi
    lsx
    lasx
"

ARCH_EXT_LIST_WASM="
    simd128
"

ARCH_EXT_LIST_X86_SIMD="
    aesni
    clmul
    amd3dnow
    amd3dnowext
    avx
    avx2
    avx512
    avx512icl
    fma3
    fma4
    mmx
    mmxext
    sse
    sse2
    sse3
    sse4
    sse42
    ssse3
    xop
"

ARCH_EXT_LIST_PPC="
    altivec
    dcbzl
    ldbrx
    power8
    ppc4xx
    vec_xl
    vsx
"

ARCH_EXT_LIST_RISCV="
    rv
    rvv
    rv_zicbop
    rv_zvbb
"

ARCH_EXT_LIST_X86="
    $ARCH_EXT_LIST_X86_SIMD
    i686
"

ARCH_EXT_LIST="
    $ARCH_EXT_LIST_ARM
    $ARCH_EXT_LIST_PPC
    $ARCH_EXT_LIST_RISCV
    $ARCH_EXT_LIST_WASM
    $ARCH_EXT_LIST_X86
    $ARCH_EXT_LIST_MIPS
    $ARCH_EXT_LIST_LOONGSON
"

ARCH_FEATURES="
    aligned_stack
    fast_64bit
    fast_clz
    fast_cmov
    fast_float16
    simd_align_16
    simd_align_32
    simd_align_64
"

BUILTIN_LIST="
    MemoryBarrier
    mm_empty
    rdtsc
    sem_timedwait
"

HAVE_LIST_CMDLINE="
    inline_asm
    symver
    x86asm
"

HAVE_LIST_PUB="
    bigendian
    fast_unaligned
"

HEADERS_LIST="
    arpa_inet_h
    asm_hwprobe_h
    asm_types_h
    cdio_paranoia_h
    cdio_paranoia_paranoia_h
    cuda_h
    dispatch_dispatch_h
    direct_h
    dirent_h
    dxgidebug_h
    dxva_h
    ES2_gl_h
    gsm_h
    io_h
    linux_dma_buf_h
    linux_perf_event_h
    malloc_h
    poll_h
    pthread_np_h
    sys_hwprobe_h
    sys_param_h
    sys_resource_h
    sys_select_h
    sys_soundcard_h
    sys_time_h
    sys_un_h
    sys_videoio_h
    termios_h
    udplite_h
    unistd_h
    valgrind_valgrind_h
    windows_h
    winsock2_h
"

INTRINSICS_LIST="
    intrinsics_neon
    intrinsics_sse2
"

MATH_FUNCS="
    atanf
    atan2f
    cbrt
    cbrtf
    copysign
    cosf
    erf
    exp2
    exp2f
    expf
    hypot
    isfinite
    isinf
    isnan
    ldexpf
    llrint
    llrintf
    log2
    log2f
    log10f
    lrint
    lrintf
    powf
    rint
    round
    roundf
    sinf
    trunc
    truncf
"

SYSTEM_FEATURES="
    dos_paths
    libc_msvcrt
    MMAL_PARAMETER_VIDEO_MAX_NUM_CALLBACKS
    section_data_rel_ro
    threads
    uwp
    winrt
"

SYSTEM_FUNCS="
    access
    aligned_malloc
    arc4random_buf
    clock_gettime
    closesocket
    CommandLineToArgvW
    elf_aux_info
    fcntl
    getaddrinfo
    getauxval
    getenv
    gethrtime
    getopt
    GetModuleHandle
    GetProcessAffinityMask
    GetProcessMemoryInfo
    GetProcessTimes
    getrusage
    GetStdHandle
    GetSystemTimeAsFileTime
    gettimeofday
    glob
    glXGetProcAddress
    gmtime_r
    inet_aton
    isatty
    kbhit
    localtime_r
    lstat
    lzo1x_999_compress
    mach_absolute_time
    MapViewOfFile
    memalign
    mkstemp
    mmap
    mprotect
    nanosleep
    PeekNamedPipe
    posix_memalign
    prctl
    pthread_cancel
    pthread_set_name_np
    pthread_setname_np
    sched_getaffinity
    SecItemImport
    SetConsoleTextAttribute
    SetConsoleCtrlHandler
    SetDllDirectory
    setmode
    setrlimit
    Sleep
    strerror_r
    sysconf
    sysctl
    sysctlbyname
    tempnam
    usleep
    UTGetOSTypeFromString
    VirtualAlloc
    wglGetProcAddress
"

SYSTEM_LIBRARIES="
    bcrypt
    vaapi_drm
    vaapi_x11
    vaapi_win32
    vdpau_x11
"

TOOLCHAIN_FEATURES="
    as_arch_directive
    as_archext_crc_directive
    as_archext_dotprod_directive
    as_archext_i8mm_directive
    as_archext_sve_directive
    as_archext_sve2_directive
    as_archext_sme_directive
    as_dn_directive
    as_fpu_directive
    as_func
    as_object_arch
    asm_mod_q
    blocks_extension
    ebp_available
    ebx_available
    gnu_as
    gnu_windres
    ibm_asm
    inline_asm_direct_symbol_refs
    inline_asm_labels
    inline_asm_nonlocal_labels
    pragma_deprecated
    rsync_contimeout
    symver_asm_label
    symver_gnu_asm
    vfp_args
    xform_asm
    xmm_clobbers
"

TYPES_LIST="
    DPI_AWARENESS_CONTEXT
    IDXGIOutput5
    __x_ABI_CWindows_CGraphics_CCapture_CIGraphicsCaptureSession5
    IDirect3DDxgiInterfaceAccess
    kCMVideoCodecType_HEVC
    kCMVideoCodecType_HEVCWithAlpha
    kCMVideoCodecType_VP9
    kCMVideoCodecType_AV1
    kCVPixelFormatType_420YpCbCr10BiPlanarVideoRange
    kCVPixelFormatType_422YpCbCr8BiPlanarVideoRange
    kCVPixelFormatType_422YpCbCr10BiPlanarVideoRange
    kCVPixelFormatType_422YpCbCr16BiPlanarVideoRange
    kCVPixelFormatType_444YpCbCr8BiPlanarVideoRange
    kCVPixelFormatType_444YpCbCr10BiPlanarVideoRange
    kCVPixelFormatType_444YpCbCr16BiPlanarVideoRange
    kCVImageBufferTransferFunction_SMPTE_ST_2084_PQ
    kCVImageBufferTransferFunction_ITU_R_2100_HLG
    kCVImageBufferTransferFunction_Linear
    kCVImageBufferYCbCrMatrix_ITU_R_2020
    kCVImageBufferColorPrimaries_ITU_R_2020
    kCVImageBufferTransferFunction_ITU_R_2020
    kCVImageBufferTransferFunction_SMPTE_ST_428_1
    kVTQPModulationLevel_Default
    SecPkgContext_KeyingMaterialInfo
    socklen_t
    struct_addrinfo
    struct_group_source_req
    struct_ip_mreq_source
    struct_ipv6_mreq
    struct_msghdr_msg_flags
    struct_pollfd
    struct_rusage_ru_maxrss
    struct_sctp_event_subscribe
    struct_sockaddr_in6
    struct_sockaddr_sa_len
    struct_sockaddr_storage
    struct_stat_st_mtim_tv_nsec
    struct_v4l2_frmivalenum_discrete
    struct_mfxConfigInterface
"

HAVE_LIST="
    $ARCH_EXT_LIST
    $(add_suffix _external $ARCH_EXT_LIST)
    $(add_suffix _inline   $ARCH_EXT_LIST)
    $ARCH_FEATURES
    $BUILTIN_LIST
    $HAVE_LIST_CMDLINE
    $HAVE_LIST_PUB
    $HEADERS_LIST
    $INTRINSICS_LIST
    $MATH_FUNCS
    $SYSTEM_FEATURES
    $SYSTEM_FUNCS
    $SYSTEM_LIBRARIES
    $THREADS_LIST
    $TOOLCHAIN_FEATURES
    $TYPES_LIST
    gzip
    ioctl_posix
    libdrm_getfb2
    makeinfo
    makeinfo_html
    opencl_d3d11
    opencl_drm_arm
    opencl_drm_beignet
    opencl_dxva2
    opencl_vaapi_beignet
    opencl_vaapi_intel_media
    opencl_videotoolbox
    perl
    pod2man
    texi2html
    xmllint
    zlib_gzip
    openvino2
"

# options emitted with CONFIG_ prefix but not available on the command line
CONFIG_EXTRA="
    aandcttables
    ac3dsp
    adts_header
    atsc_a53
    audio_frame_queue
    audiodsp
    blockdsp
    bswapdsp
    cabac
    cbs
    cbs_apv
    cbs_av1
    cbs_h264
    cbs_h265
    cbs_h266
    cbs_jpeg
    cbs_mpeg2
    cbs_vp8
    cbs_vp9
    celp_math
    d3d12_intra_refresh
    d3d12_motion_estimator
    d3d12va_encode
    d3d12va_me_precision_eighth_pixel
    deflate_wrapper
    dirac_parse
    dnn
    dovi_rpudec
    dovi_rpuenc
    dvprofile
    evcparse
    faandct
    faanidct
    fdctdsp
    fmtconvert
    frame_thread_encoder
    g722dsp
    golomb
    gplv3
    h263dsp
    h264chroma
    h264dsp
    h264parse
    h264pred
    h264qpel
    h264_sei
    hevcparse
    hevc_sei
    hpeldsp
    huffman
    huffyuvdsp
    huffyuvencdsp
    iamfdec
    iamfenc
    idctdsp
    inflate_wrapper
    intrax8
    iso_media
    iso_writer
    ividsp
    jpegtables
    lgplv3
    libx262
    libx264_hdr10
    llauddsp
    llviddsp
    llvidencdsp
    lpc
    lzf
    me_cmp
    mpeg_er
    mpegaudio
    mpegaudiodsp
    mpegaudioheader
    mpeg4audio
    mpegvideo
    mpegvideodec
    mpegvideoenc
    mpegvideoencdsp
    msmpeg4dec
    msmpeg4enc
    mss34dsp
    pixblockdsp
    qpeldsp
    qsv
    qsvdec
    qsvenc
    qsvvpp
    rangecoder
    riffdec
    riffenc
    rtpdec
    rtpenc_chain
    rv34dsp
    scene_sad
    sinewin
    smpte_436m
    snappy
    srtp
    startcode
    texturedsp
    texturedspenc
    tpeldsp
    vaapi_1
    vaapi_encode
    vulkan_1_4
    vc1dsp
    videodsp
    vp3dsp
    vp8dsp
    vulkan_encode
    vvc_sei
    wma_freqs
    wmv2dsp
"

CMDLINE_SELECT="
    $ARCH_EXT_LIST
    $CONFIG_LIST
    $HAVE_LIST_CMDLINE
    $THREADS_LIST
    asm
    cross_compile
    debug
    extra_warnings
    logging
    optimizations
    preserve_temps
    response_files
    rpath
    stripping
    version_tracking
"

PATHS_LIST="
    bindir
    datadir
    docdir
    incdir
    libdir
    mandir
    pkgconfigdir
    prefix
    shlibdir
    install_name_dir
"

CMDLINE_SET="
    $PATHS_LIST
    ar
    arch
    as
    assert_level
    build_suffix
    cc
    objcc
    cpu
    cross_prefix
    custom_allocator
    cxx
    dep_cc
    doxygen
    env
    extra_version
    gas
    host_cc
    host_cflags
    host_extralibs
    host_ld
    host_ldflags
    host_os
    ignore_tests
    install
    ld
    ln_s
    logfile
    malloc_prefix
    glslc
    glslcflags
    metalcc
    metallib
    nm
    optflags
    nvcc
    nvccflags
    pkg_config
    pkg_config_flags
    progs_suffix
    random_seed
    ranlib
    samples
    stdc
    stdcxx
    strip
    sws_max_filter_size
    sysinclude
    sysroot
    target_exec
    target_os
    tempprefix
    toolchain
    windres
    x86asmexe
    "

CMDLINE_APPEND="
    extra_cflags
    extra_cxxflags
    extra_objcflags
    host_cppflags
"

# code dependency declarations

# architecture extensions

armv5te_deps="arm"
armv6_deps="arm"
armv6t2_deps="arm"
armv8_deps="aarch64"
neon_deps_any="aarch64 arm"
intrinsics_neon_deps="neon"
intrinsics_sse2_deps="sse2"
vfp_deps="arm"
vfpv3_deps="vfp"
setend_deps="arm"
arm_crc_deps="aarch64"
dotprod_deps="aarch64 neon"
i8mm_deps="aarch64 neon"
sve_deps="aarch64 neon"
sve2_deps="aarch64 neon sve"
sme_deps="aarch64 neon sve sve2"

map 'eval ${v}_inline_deps=inline_asm' $ARCH_EXT_LIST_ARM

altivec_deps="ppc"
dcbzl_deps="ppc"
ldbrx_deps="ppc"
ppc4xx_deps="ppc"
vec_xl_deps="altivec"
vsx_deps="altivec"
power8_deps="vsx"

rv_deps="riscv"
rvv_deps="rv"
rv_zicbop="riscv"
rv_zvbb_deps="rvv"

loongson2_deps="mips"
loongson3_deps="mips"
mmi_deps_any="loongson2 loongson3"
lsx_deps="loongarch"
lasx_deps="lsx"

mips32r2_deps="mips"
mips32r5_deps="mips"
mips32r6_deps="mips"
mips64r2_deps="mips"
mips64r6_deps="mips"
mipsfpu_deps="mips"
mipsdsp_deps="mips"
mipsdspr2_deps="mips"
msa_deps="mipsfpu"

simd128_deps="wasm"

x86_64_select="i686"
x86_64_suggest="fast_cmov"

i686_deps="x86"
mmx_deps="x86"
mmxext_deps="mmx"
sse_deps="mmxext"
sse2_deps="sse"
sse3_deps="sse2"
ssse3_deps="sse3"
sse4_deps="ssse3"
sse42_deps="sse4"
aesni_deps="sse42"
clmul_deps="sse42"
avx_deps="sse42"
xop_deps="avx"
fma3_deps="avx"
fma4_deps="avx"
avx2_deps="avx"
avx512_deps="avx2"
avx512icl_deps="avx512"

mmx_external_deps="x86asm"
mmx_inline_deps="inline_asm x86"
mmx_suggest="mmx_external mmx_inline"

for ext in $(filter_out mmx $ARCH_EXT_LIST_X86_SIMD); do
    eval dep=\$${ext}_deps
    eval ${ext}_external_deps='"${dep}_external"'
    eval ${ext}_inline_deps='"${dep}_inline"'
    eval ${ext}_suggest='"${ext}_external ${ext}_inline"'
done

aligned_stack_if_any="aarch64 ppc x86"
fast_64bit_if_any="aarch64 ia64 mips64 parisc64 ppc64 riscv64 sparc64 x86_64"
fast_clz_if_any="aarch64 mips ppc x86"
fast_unaligned_if_any="aarch64 ppc x86"
simd_align_16_if_any="altivec neon sse"
simd_align_32_if_any="avx"
simd_align_64_if_any="avx512"

# system capabilities
linux_perf_deps="linux_perf_event_h"
symver_if_any="symver_asm_label symver_gnu_asm"
valgrind_backtrace_conflict="optimizations"
valgrind_backtrace_deps="valgrind_valgrind_h"

# threading support
atomics_win32_if="MemoryBarrier"
atomics_native_if_any="$ATOMICS_LIST"
w32threads_deps="atomics_native"
threads_if_any="$THREADS_LIST"

# subsystems
cbs_apv_select="cbs"
cbs_av1_select="cbs"
cbs_h264_select="cbs"
cbs_h265_select="cbs"
cbs_h266_select="cbs"
cbs_jpeg_select="cbs"
cbs_mpeg2_select="cbs"
cbs_vp8_select="cbs"
cbs_vp9_select="cbs"
deflate_wrapper_deps="zlib"
dirac_parse_select="golomb"
dovi_rpudec_select="golomb"
dovi_rpuenc_select="golomb"
dnn_deps="avformat swscale"
dnn_deps_any="libtensorflow libopenvino libtorch"
error_resilience_select="me_cmp"
evcparse_select="golomb"
faandct_deps="faan"
faandct_select="fdctdsp"
faanidct_deps="faan"
faanidct_select="idctdsp"
h264dsp_select="startcode"
h264parse_select="golomb"
h264_sei_select="atsc_a53 golomb"
hevcparse_select="golomb"
hevc_sei_select="atsc_a53 golomb"
iso_writer_select="golomb"
frame_thread_encoder_deps="encoders threads"
iamfdec_deps="iamf"
iamfdec_select="iso_media mpeg4audio"
iamfenc_deps="iamf"
inflate_wrapper_deps="zlib"
intrax8_select="blockdsp wmv2dsp"
iso_media_select="mpeg4audio"
me_cmp_select="idctdsp"
mpeg_er_select="error_resilience"
mpegaudio_select="mpegaudiodsp mpegaudioheader"
mpegvideo_select="blockdsp hpeldsp idctdsp videodsp"
mpegvideoc_dec_select="h264chroma mpegvideo mpeg_er"
mpegvideoenc_select="aandcttables fdctdsp me_cmp mpegvideo mpegvideoencdsp pixblockdsp"
msmpeg4dec_select="h263_decoder"
msmpeg4enc_select="h263_encoder"
vc1dsp_select="h264chroma startcode"
vvc_sei_select="atsc_a53 golomb"
wmv2dsp_select="idctdsp"

# decoders / encoders
aac_decoder_select="adts_header mpeg4audio sinewin"
aac_fixed_decoder_select="adts_header mpeg4audio"
aac_encoder_select="audio_frame_queue lpc sinewin"
aac_latm_decoder_select="aac_decoder aac_latm_parser"
ac3_decoder_select="ac3_parser ac3dsp bswapdsp fmtconvert"
ac3_fixed_decoder_select="ac3_parser ac3dsp bswapdsp"
ac3_encoder_select="ac3dsp audiodsp me_cmp"
ac3_fixed_encoder_select="ac3dsp audiodsp me_cmp"
acelp_kelvin_decoder_select="audiodsp celp_math"
adpcm_circus_decoder_deps="lgpl_gpl"
adpcm_g722_decoder_select="g722dsp"
adpcm_g722_encoder_select="g722dsp"
adpcm_ima_escape_decoder_deps="lgpl_gpl"
adpcm_ima_hvqm2_decoder_deps="lgpl_gpl"
adpcm_ima_hvqm4_decoder_deps="lgpl_gpl"
adpcm_ima_magix_decoder_deps="lgpl_gpl"
adpcm_ima_pda_decoder_deps="lgpl_gpl"
adpcm_n64_decoder_deps="lgpl_gpl"
adpcm_psxc_decoder_deps="lgpl_gpl"
agm_decoder_select="idctdsp"
ahx_decoder_deps="lgpl_gpl"
ahx_decoder_select="mpegaudio ahx_to_mp2_bsf"
aic_decoder_select="golomb idctdsp"
alac_encoder_select="lpc"
als_decoder_select="bswapdsp mpeg4audio"
amrnb_decoder_select="lsp celp_math"
amrwb_decoder_select="lsp celp_math"
amv_decoder_select="sp5x_decoder"
amv_encoder_select="jpegtables mpegvideoenc"
ape_decoder_select="bswapdsp llauddsp"
apng_decoder_select="inflate_wrapper"
apng_encoder_select="deflate_wrapper llvidencdsp"
aptx_encoder_select="audio_frame_queue"
aptx_hd_encoder_select="audio_frame_queue"
apv_decoder_select="cbs_apv"
asv1_decoder_select="blockdsp bswapdsp idctdsp"
asv1_encoder_select="aandcttables bswapdsp fdctdsp pixblockdsp"
asv2_decoder_select="blockdsp bswapdsp idctdsp"
asv2_encoder_select="aandcttables bswapdsp fdctdsp pixblockdsp"
atrac1_decoder_select="sinewin"
atrac3p_decoder_select="sinewin"
atrac3pal_decoder_select="sinewin"
av1_decoder_select="atsc_a53 cbs_av1 dovi_rpudec"
bink_decoder_select="blockdsp hpeldsp"
binkaudio_dct_decoder_select="wma_freqs"
binkaudio_rdft_decoder_select="wma_freqs"
cavs_decoder_select="blockdsp golomb h264chroma idctdsp qpeldsp videodsp"
clearvideo_decoder_select="idctdsp"
cllc_decoder_select="bswapdsp"
comfortnoise_encoder_select="lpc"
cook_decoder_select="audiodsp sinewin"
cri_decoder_select="mjpeg_decoder"
cscd_decoder_suggest="zlib"
dds_decoder_select="texturedsp"
dirac_decoder_select="dirac_parse dwt golomb mpegvideoencdsp qpeldsp videodsp"
dnxhd_decoder_select="blockdsp idctdsp"
dnxhd_encoder_select="blockdsp fdctdsp idctdsp mpegvideoenc pixblockdsp videodsp"
dvvideo_decoder_select="dvprofile idctdsp"
dvvideo_encoder_select="dvprofile fdctdsp me_cmp pixblockdsp"
dxa_decoder_deps="zlib"
dxv_decoder_select="lzf texturedsp"
dxv_encoder_select="texturedspenc"
eac3_decoder_select="ac3_decoder"
eac3_encoder_select="ac3_encoder"
eamad_decoder_select="aandcttables blockdsp bswapdsp"
eatgq_decoder_select="aandcttables"
eatqi_decoder_select="aandcttables blockdsp bswapdsp"
exr_decoder_deps="zlib"
exr_decoder_select="bswapdsp"
exr_encoder_deps="zlib"
ffv1_decoder_select="rangecoder"
ffv1_encoder_select="rangecoder"
ffv1_vulkan_encoder_select="vulkan spirv_library"
ffvhuff_decoder_select="huffyuv_decoder"
ffvhuff_encoder_select="huffyuv_encoder"
fic_decoder_select="golomb"
flac_encoder_select="bswapdsp lpc"
flashsv2_decoder_select="inflate_wrapper"
flashsv2_encoder_select="deflate_wrapper"
flashsv_decoder_select="inflate_wrapper"
flashsv_encoder_deps="zlib"
flv_decoder_select="h263_decoder"
flv_encoder_select="h263_encoder"
fourxm_decoder_select="blockdsp bswapdsp"
fraps_decoder_select="bswapdsp huffman"
ftr_decoder_select="adts_header"
g2m_decoder_deps="zlib"
g2m_decoder_select="blockdsp idctdsp jpegtables"
g723_1_decoder_select="celp_math"
g723_1_encoder_select="celp_math"
g729_decoder_select="audiodsp celp_math"
h261_decoder_select="mpegvideodec"
h261_encoder_select="mpegvideoenc"
h263_decoder_select="h263dsp mpegvideodec"
h263_encoder_select="h263dsp mpegvideoenc"
h263i_decoder_select="h263_decoder"
h263p_decoder_select="h263_decoder"
h263p_encoder_select="h263_encoder"
h264_decoder_select="cabac golomb h264chroma h264dsp h264parse h264pred h264qpel h264_sei videodsp"
h264_decoder_suggest="error_resilience"
hap_decoder_select="snappy texturedsp"
hap_encoder_deps="libsnappy"
hap_encoder_select="texturedspenc"
hevc_decoder_select="bswapdsp cabac dovi_rpudec golomb hevcparse hevc_sei videodsp"
huffyuv_decoder_select="bswapdsp huffyuvdsp llviddsp"
huffyuv_encoder_select="bswapdsp huffman huffyuvencdsp llvidencdsp"
hymt_decoder_select="huffyuv_decoder"
iac_decoder_select="imc_decoder"
imc_decoder_select="bswapdsp sinewin"
imm4_decoder_select="bswapdsp idctdsp"
imm5_decoder_select="h264_decoder hevc_decoder"
indeo3_decoder_select="hpeldsp"
indeo4_decoder_select="ividsp"
indeo5_decoder_select="ividsp"
interplay_video_decoder_select="hpeldsp"
ipu_decoder_select="mpegvideodec"
jpegls_decoder_select="mjpeg_decoder"
jv_decoder_select="blockdsp"
lagarith_decoder_select="llviddsp"
lead_decoder_select="blockdsp idctdsp jpegtables"
ljpeg_encoder_select="jpegtables"
lscr_decoder_select="inflate_wrapper"
magicyuv_decoder_select="llviddsp"
magicyuv_encoder_select="llvidencdsp"
mdec_decoder_select="blockdsp bswapdsp idctdsp"
media100_decoder_select="media100_to_mjpegb_bsf mjpegb_decoder"
metasound_decoder_select="lsp sinewin"
mimic_decoder_select="blockdsp bswapdsp hpeldsp idctdsp"
mjpeg_decoder_select="blockdsp idctdsp jpegtables"
mjpeg_encoder_select="jpegtables mpegvideoenc"
mjpegb_decoder_select="hpeldsp mjpeg_decoder"
mlp_decoder_select="mlp_parser"
mlp_encoder_select="lpc audio_frame_queue"
mobiclip_decoder_select="bswapdsp golomb"
motionpixels_decoder_select="bswapdsp"
mp1_decoder_select="mpegaudio"
mp1float_decoder_select="mpegaudio"
mp2_decoder_select="mpegaudio"
mp2float_decoder_select="mpegaudio"
mp3_decoder_select="mpegaudio"
mp3adu_decoder_select="mpegaudio"
mp3adufloat_decoder_select="mpegaudio"
mp3float_decoder_select="mpegaudio"
mp3on4_decoder_select="mpegaudio mpeg4audio"
mp3on4float_decoder_select="mpegaudio mpeg4audio"
mpc7_decoder_select="bswapdsp mpegaudiodsp"
mpc8_decoder_select="mpegaudiodsp"
mpegvideo_decoder_select="mpegvideodec"
mpeg1video_decoder_select="mpegvideodec"
mpeg1video_encoder_select="mpegvideoenc"
mpeg2video_decoder_select="mpegvideodec"
mpeg2video_encoder_select="mpegvideoenc"
mpeg4_decoder_select="h263_decoder qpeldsp"
mpeg4_encoder_select="h263_encoder qpeldsp"
msa1_decoder_select="mss34dsp"
mscc_decoder_select="inflate_wrapper"
msmpeg4v1_decoder_select="msmpeg4dec"
msmpeg4v2_decoder_select="msmpeg4dec"
msmpeg4v2_encoder_select="msmpeg4enc"
msmpeg4v3_decoder_select="msmpeg4dec"
msmpeg4v3_encoder_select="msmpeg4enc"
mss2_decoder_select="mpegvideodec vc1_decoder"
mts2_decoder_select="jpegtables mss34dsp"
mv30_decoder_select="aandcttables blockdsp"
mvha_decoder_select="inflate_wrapper llviddsp"
mwsc_decoder_select="inflate_wrapper"
mxpeg_decoder_select="hpeldsp mjpeg_decoder"
nellymoser_decoder_select="sinewin"
nellymoser_encoder_select="audio_frame_queue sinewin"
notchlc_decoder_select="lzf"
nuv_decoder_select="idctdsp"
opus_decoder_deps="swresample"
opus_encoder_select="audio_frame_queue"
pdv_decoder_select="inflate_wrapper"
png_decoder_select="inflate_wrapper"
png_encoder_select="deflate_wrapper llvidencdsp"
prores_decoder_select="blockdsp idctdsp"
prores_encoder_select="fdctdsp"
prores_aw_encoder_select="fdctdsp"
prores_ks_encoder_select="fdctdsp"
prores_raw_decoder_select="blockdsp idctdsp"
qcelp_decoder_select="lsp"
qdm2_decoder_select="mpegaudiodsp"
ra_144_decoder_select="audiodsp"
ra_144_encoder_select="audio_frame_queue lpc audiodsp"
ralf_decoder_select="golomb"
rasc_decoder_select="inflate_wrapper"
rawvideo_decoder_select="bswapdsp"
rscc_decoder_deps="zlib"
rtv1_decoder_select="texturedsp"
rv10_decoder_select="h263_decoder"
rv10_encoder_select="h263_encoder"
rv20_decoder_select="h263_decoder"
rv20_encoder_select="h263_encoder"
rv30_decoder_select="golomb h264pred h264qpel mpegvideodec rv34dsp"
rv40_decoder_select="golomb h264pred h264qpel mpegvideodec rv34dsp"
rv60_decoder_select="videodsp golomb"
screenpresso_decoder_deps="zlib"
shorten_decoder_select="bswapdsp"
sipr_decoder_select="lsp celp_math"
smvjpeg_decoder_select="mjpeg_decoder"
snow_decoder_select="dwt h264qpel rangecoder videodsp"
snow_encoder_select="dwt h264qpel hpeldsp me_cmp mpegvideoencdsp rangecoder videodsp"
sonic_decoder_select="golomb rangecoder"
sonic_encoder_select="golomb rangecoder"
sonic_ls_encoder_select="golomb rangecoder"
sp5x_decoder_select="mjpeg_decoder"
speedhq_decoder_select="blockdsp idctdsp"
speedhq_encoder_select="mpegvideoenc"
srgc_decoder_select="inflate_wrapper"
svq1_decoder_select="hpeldsp"
svq1_encoder_select="hpeldsp me_cmp mpegvideoencdsp"
svq3_decoder_select="golomb h264dsp h264parse h264pred hpeldsp tpeldsp videodsp"
svq3_decoder_suggest="zlib"
tak_decoder_select="audiodsp"
tdsc_decoder_deps="zlib"
tdsc_decoder_select="mjpeg_decoder"
theora_decoder_select="vp3_decoder"
thp_decoder_select="mjpeg_decoder"
tiff_decoder_select="mjpeg_decoder"
tiff_decoder_suggest="zlib lzma"
tiff_encoder_suggest="zlib"
truehd_decoder_select="mlp_parser"
truehd_encoder_select="lpc audio_frame_queue"
truemotion2_decoder_select="bswapdsp"
truespeech_decoder_select="bswapdsp"
tscc_decoder_select="inflate_wrapper"
twinvq_decoder_select="lsp sinewin"
txd_decoder_select="texturedsp"
utvideo_decoder_select="bswapdsp llviddsp"
utvideo_encoder_select="bswapdsp huffman llvidencdsp"
vble_decoder_select="llviddsp"
vbn_decoder_select="texturedsp"
vbn_encoder_select="texturedspenc"
vmix_decoder_select="idctdsp"
vc1_decoder_select="blockdsp h264qpel intrax8 mpegvideoc_dec qpeldsp vc1dsp"
vc1image_decoder_select="vc1_decoder"
vorbis_encoder_select="audio_frame_queue"
vp3_decoder_select="hpeldsp vp3dsp videodsp"
vp4_decoder_select="vp3_decoder"
vp5_decoder_select="h264chroma hpeldsp videodsp vp3dsp"
vp6_decoder_select="h264chroma hpeldsp huffman videodsp vp3dsp"
vp6a_decoder_select="vp6_decoder"
vp6f_decoder_select="vp6_decoder"
vp7_decoder_select="h264pred videodsp vp8dsp"
vp8_decoder_select="h264pred videodsp vp8dsp"
vp9_decoder_select="videodsp vp9_parser cbs_vp9 vp9_superframe_split_bsf"
vvc_decoder_select="cabac cbs_h266 golomb videodsp vvc_sei"
wcmv_decoder_select="inflate_wrapper"
webp_decoder_select="vp8_decoder"
wmalossless_decoder_select="llauddsp"
wmapro_decoder_select="sinewin wma_freqs"
wmav1_decoder_select="sinewin wma_freqs"
wmav1_encoder_select="sinewin wma_freqs"
wmav2_decoder_select="sinewin wma_freqs"
wmav2_encoder_select="sinewin wma_freqs"
wmavoice_decoder_select="lsp sinewin"
wmv1_decoder_select="msmpeg4dec"
wmv1_encoder_select="msmpeg4enc"
wmv2_decoder_select="blockdsp error_resilience idctdsp intrax8 msmpeg4dec qpeldsp videodsp wmv2dsp"
wmv2_encoder_select="msmpeg4enc wmv2dsp"
wmv3_decoder_select="vc1_decoder"
wmv3image_decoder_select="wmv3_decoder"
xma1_decoder_select="wmapro_decoder"
xma2_decoder_select="wmapro_decoder"
ylc_decoder_select="bswapdsp"
zerocodec_decoder_select="inflate_wrapper"
zlib_decoder_select="inflate_wrapper"
zlib_encoder_select="deflate_wrapper"
zmbv_decoder_select="inflate_wrapper"
zmbv_encoder_select="deflate_wrapper"

# hardware accelerators
cuda_deps="ffnvcodec"
cuvid_deps="ffnvcodec"
d3d11va_deps="dxva_h ID3D11VideoDecoder ID3D11VideoContext"
d3d12va_deps="dxva_h ID3D12Device ID3D12VideoDecoder"
dxva2_deps="dxva2api_h DXVA2_ConfigPictureDecode ole32 user32"
ffnvcodec_deps_any="libdl LoadLibrary"
mediacodec_deps="android mediandk pthreads"
nvdec_deps="ffnvcodec"
vaapi_x11_deps="xlib_x11"
videotoolbox_hwaccel_deps="videotoolbox pthreads"
videotoolbox_hwaccel_extralibs="-framework QuartzCore"
vulkan_deps="threads"
vulkan_deps_any="libdl LoadLibrary"

av1_d3d11va_hwaccel_deps="d3d11va DXVA_PicParams_AV1"
av1_d3d11va_hwaccel_select="av1_decoder"
av1_d3d11va2_hwaccel_deps="d3d11va DXVA_PicParams_AV1"
av1_d3d11va2_hwaccel_select="av1_decoder"
av1_d3d12va_hwaccel_deps="d3d12va DXVA_PicParams_AV1"
av1_d3d12va_hwaccel_select="av1_decoder"
av1_dxva2_hwaccel_deps="dxva2 DXVA_PicParams_AV1"
av1_dxva2_hwaccel_select="av1_decoder"
av1_nvdec_hwaccel_deps="nvdec CUVIDAV1PICPARAMS"
av1_nvdec_hwaccel_select="av1_decoder"
av1_vaapi_hwaccel_deps="vaapi VADecPictureParameterBufferAV1_bit_depth_idx"
av1_vaapi_hwaccel_select="av1_decoder"
av1_vdpau_hwaccel_deps="vdpau VdpPictureInfoAV1"
av1_vdpau_hwaccel_select="av1_decoder"
av1_videotoolbox_hwaccel_deps="videotoolbox"
av1_videotoolbox_hwaccel_select="av1_decoder"
av1_vulkan_hwaccel_deps="vulkan"
av1_vulkan_hwaccel_select="av1_decoder"
dpx_vulkan_hwaccel_deps="vulkan spirv_compiler"
dpx_vulkan_hwaccel_select="dpx_decoder"
ffv1_vulkan_hwaccel_deps="vulkan spirv_library"
ffv1_vulkan_hwaccel_select="ffv1_decoder"
h263_vaapi_hwaccel_deps="vaapi"
h263_vaapi_hwaccel_select="h263_decoder"
h263_videotoolbox_hwaccel_deps="videotoolbox"
h263_videotoolbox_hwaccel_select="h263_decoder"
h264_d3d11va_hwaccel_deps="d3d11va"
h264_d3d11va_hwaccel_select="h264_decoder"
h264_d3d11va2_hwaccel_deps="d3d11va"
h264_d3d11va2_hwaccel_select="h264_decoder"
h264_d3d12va_hwaccel_deps="d3d12va"
h264_d3d12va_hwaccel_select="h264_decoder"
h264_dxva2_hwaccel_deps="dxva2"
h264_dxva2_hwaccel_select="h264_decoder"
h264_nvdec_hwaccel_deps="nvdec"
h264_nvdec_hwaccel_select="h264_decoder"
h264_vaapi_hwaccel_deps="vaapi"
h264_vaapi_hwaccel_select="h264_decoder"
h264_vdpau_hwaccel_deps="vdpau"
h264_vdpau_hwaccel_select="h264_decoder"
h264_videotoolbox_hwaccel_deps="videotoolbox"
h264_videotoolbox_hwaccel_select="h264_decoder"
h264_vulkan_hwaccel_deps="vulkan"
h264_vulkan_hwaccel_select="h264_decoder"
hevc_d3d11va_hwaccel_deps="d3d11va DXVA_PicParams_HEVC"
hevc_d3d11va_hwaccel_select="hevc_decoder"
hevc_d3d11va2_hwaccel_deps="d3d11va DXVA_PicParams_HEVC"
hevc_d3d11va2_hwaccel_select="hevc_decoder"
hevc_d3d12va_hwaccel_deps="d3d12va DXVA_PicParams_HEVC"
hevc_d3d12va_hwaccel_select="hevc_decoder"
hevc_dxva2_hwaccel_deps="dxva2 DXVA_PicParams_HEVC"
hevc_dxva2_hwaccel_select="hevc_decoder"
hevc_nvdec_hwaccel_deps="nvdec"
hevc_nvdec_hwaccel_select="hevc_decoder"
hevc_vaapi_hwaccel_deps="vaapi VAPictureParameterBufferHEVC"
hevc_vaapi_hwaccel_select="hevc_decoder"
hevc_vdpau_hwaccel_deps="vdpau VdpPictureInfoHEVC"
hevc_vdpau_hwaccel_select="hevc_decoder"
hevc_videotoolbox_hwaccel_deps="videotoolbox"
hevc_videotoolbox_hwaccel_select="hevc_decoder"
hevc_vulkan_hwaccel_deps="vulkan"
hevc_vulkan_hwaccel_select="hevc_decoder"
mjpeg_nvdec_hwaccel_deps="nvdec"
mjpeg_nvdec_hwaccel_select="mjpeg_decoder"
mjpeg_vaapi_hwaccel_deps="vaapi"
mjpeg_vaapi_hwaccel_select="mjpeg_decoder"
mpeg1_nvdec_hwaccel_deps="nvdec"
mpeg1_nvdec_hwaccel_select="mpeg1video_decoder"
mpeg1_vdpau_hwaccel_deps="vdpau"
mpeg1_vdpau_hwaccel_select="mpeg1video_decoder"
mpeg1_videotoolbox_hwaccel_deps="videotoolbox"
mpeg1_videotoolbox_hwaccel_select="mpeg1video_decoder"
mpeg2_d3d11va_hwaccel_deps="d3d11va"
mpeg2_d3d11va_hwaccel_select="mpeg2video_decoder"
mpeg2_d3d11va2_hwaccel_deps="d3d11va"
mpeg2_d3d11va2_hwaccel_select="mpeg2video_decoder"
mpeg2_d3d12va_hwaccel_deps="d3d12va"
mpeg2_d3d12va_hwaccel_select="mpeg2video_decoder"
mpeg2_dxva2_hwaccel_deps="dxva2"
mpeg2_dxva2_hwaccel_select="mpeg2video_decoder"
mpeg2_nvdec_hwaccel_deps="nvdec"
mpeg2_nvdec_hwaccel_select="mpeg2video_decoder"
mpeg2_vaapi_hwaccel_deps="vaapi"
mpeg2_vaapi_hwaccel_select="mpeg2video_decoder"
mpeg2_vdpau_hwaccel_deps="vdpau"
mpeg2_vdpau_hwaccel_select="mpeg2video_decoder"
mpeg2_videotoolbox_hwaccel_deps="videotoolbox"
mpeg2_videotoolbox_hwaccel_select="mpeg2video_decoder"
mpeg4_nvdec_hwaccel_deps="nvdec"
mpeg4_nvdec_hwaccel_select="mpeg4_decoder"
mpeg4_vaapi_hwaccel_deps="vaapi"
mpeg4_vaapi_hwaccel_select="mpeg4_decoder"
mpeg4_vdpau_hwaccel_deps="vdpau"
mpeg4_vdpau_hwaccel_select="mpeg4_decoder"
mpeg4_videotoolbox_hwaccel_deps="videotoolbox"
mpeg4_videotoolbox_hwaccel_select="mpeg4_decoder"
prores_videotoolbox_hwaccel_deps="pthreads"
prores_videotoolbox_hwaccel_select="videotoolbox_encoder"
prores_raw_vulkan_hwaccel_deps="vulkan spirv_compiler"
prores_raw_vulkan_hwaccel_select="prores_raw_decoder"
prores_vulkan_hwaccel_deps="vulkan spirv_compiler"
prores_vulkan_hwaccel_select="prores_decoder"
vc1_d3d11va_hwaccel_deps="d3d11va"
vc1_d3d11va_hwaccel_select="vc1_decoder"
vc1_d3d11va2_hwaccel_deps="d3d11va"
vc1_d3d11va2_hwaccel_select="vc1_decoder"
vc1_d3d12va_hwaccel_deps="d3d12va"
vc1_d3d12va_hwaccel_select="vc1_decoder"
vc1_dxva2_hwaccel_deps="dxva2"
vc1_dxva2_hwaccel_select="vc1_decoder"
vc1_nvdec_hwaccel_deps="nvdec"
vc1_nvdec_hwaccel_select="vc1_decoder"
vc1_vaapi_hwaccel_deps="vaapi"
vc1_vaapi_hwaccel_select="vc1_decoder"
vc1_vdpau_hwaccel_deps="vdpau"
vc1_vdpau_hwaccel_select="vc1_decoder"
vp8_cuvid_decoder_deps="cuvid"
vp8_mediacodec_decoder_deps="mediacodec"
vp8_mediacodec_encoder_deps="mediacodec"
vp8_qsv_decoder_select="qsvdec"
vp8_rkmpp_decoder_deps="rkmpp"
vp8_vaapi_encoder_deps="VAEncPictureParameterBufferVP8"
vp8_vaapi_encoder_select="vaapi_encode"
vp8_v4l2m2m_decoder_deps="v4l2_m2m vp8_v4l2_m2m"
vp8_v4l2m2m_encoder_deps="v4l2_m2m vp8_v4l2_m2m"
vp9_amf_decoder_deps="amf"
vp9_cuvid_decoder_deps="cuvid"
vp9_mediacodec_decoder_deps="mediacodec"
vp9_mediacodec_encoder_deps="mediacodec"
vp9_qsv_decoder_select="qsvdec"
vp9_rkmpp_decoder_deps="rkmpp"
vp9_vaapi_encoder_deps="VAEncPictureParameterBufferVP9"
vp9_vaapi_encoder_select="vaapi_encode"
vp9_qsv_encoder_deps="libmfx MFX_CODEC_VP9"
vp9_qsv_encoder_select="qsvenc"
vp9_v4l2m2m_decoder_deps="v4l2_m2m vp9_v4l2_m2m"
amf_capture_filter_deps="amf"
vvc_qsv_decoder_select="vvc_mp4toannexb_bsf qsvdec"

# parsers
aac_parser_select="adts_header mpeg4audio"
ahx_parser_deps="lgpl_gpl"
apv_parser_select="cbs_apv"
av1_parser_select="cbs_av1"
evc_parser_select="evcparse"
ffv1_parser_select="rangecoder"
ftr_parser_select="adts_header mpeg4audio"
h264_parser_select="golomb h264dsp h264parse h264_sei"
hevc_parser_select="hevcparse hevc_sei"
mpegaudio_parser_select="mpegaudioheader"
mpeg4video_parser_select="mpegvideodec"
vc1_parser_select="vc1dsp"
vvc_parser_select="cbs_h266"

# bitstream_filters
aac_adtstoasc_bsf_select="adts_header mpeg4audio"
ahx_to_mp2_bsf_deps="lgpl_gpl"
av1_frame_merge_bsf_select="cbs_av1"
av1_frame_split_bsf_select="cbs_av1"
av1_metadata_bsf_select="cbs_av1"
dovi_rpu_bsf_select="cbs_h265 cbs_av1 dovi_rpudec dovi_rpuenc"
dts2pts_bsf_select="cbs_h264 h264parse cbs_h265 hevc_parser"
eac3_core_bsf_select="ac3_parser"
eia608_to_smpte436m_bsf_select="smpte_436m"
evc_frame_merge_bsf_select="evcparse"
filter_units_bsf_select="cbs"
h264_metadata_bsf_deps="const_nan"
h264_metadata_bsf_select="cbs_h264"
h264_redundant_pps_bsf_select="cbs_h264"
hevc_metadata_bsf_select="cbs_h265"
mjpeg2jpeg_bsf_select="jpegtables"
mpeg2_metadata_bsf_select="cbs_mpeg2"
smpte436m_to_eia608_bsf_select="smpte_436m"
trace_headers_bsf_select="cbs cbs_vp8"
vp9_metadata_bsf_select="cbs_vp9"
vvc_metadata_bsf_select="cbs_h266"

# external libraries
aac_at_decoder_deps="audiotoolbox"
aac_at_decoder_select="aac_adtstoasc_bsf"
ac3_at_decoder_deps="audiotoolbox"
ac3_at_decoder_select="ac3_parser"
adpcm_ima_qt_at_decoder_deps="audiotoolbox"
alac_at_decoder_deps="audiotoolbox"
amr_nb_at_decoder_deps="audiotoolbox"
avisynth_deps_any="libdl LoadLibrary"
avisynth_demuxer_deps="avisynth"
avisynth_demuxer_select="riffdec"
eac3_at_decoder_deps="audiotoolbox"
eac3_at_decoder_select="ac3_parser"
gsm_ms_at_decoder_deps="audiotoolbox"
ilbc_at_decoder_deps="audiotoolbox"
mp1_at_decoder_deps="audiotoolbox"
mp2_at_decoder_deps="audiotoolbox"
mp3_at_decoder_deps="audiotoolbox"
mp1_at_decoder_select="mpegaudioheader"
mp2_at_decoder_select="mpegaudioheader"
mp3_at_decoder_select="mpegaudioheader"
pcm_alaw_at_decoder_deps="audiotoolbox"
pcm_mulaw_at_decoder_deps="audiotoolbox"
qdmc_at_decoder_deps="audiotoolbox"
qdm2_at_decoder_deps="audiotoolbox"
aac_at_encoder_deps="audiotoolbox"
aac_at_encoder_select="audio_frame_queue"
alac_at_encoder_deps="audiotoolbox"
alac_at_encoder_select="audio_frame_queue"
ilbc_at_encoder_deps="audiotoolbox"
ilbc_at_encoder_select="audio_frame_queue"
pcm_alaw_at_encoder_deps="audiotoolbox"
pcm_alaw_at_encoder_select="audio_frame_queue"
pcm_mulaw_at_encoder_deps="audiotoolbox"
pcm_mulaw_at_encoder_select="audio_frame_queue"
chromaprint_muxer_deps="chromaprint"
h264_videotoolbox_encoder_deps="pthreads"
h264_videotoolbox_encoder_select="atsc_a53 videotoolbox_encoder"
hevc_videotoolbox_encoder_deps="pthreads"
hevc_videotoolbox_encoder_select="atsc_a53 videotoolbox_encoder"
prores_videotoolbox_encoder_deps="pthreads"
prores_videotoolbox_encoder_select="videotoolbox_encoder"
libaom_av1_decoder_deps="libaom"
libaom_av1_encoder_deps="libaom"
libaom_av1_encoder_select="extract_extradata_bsf dovi_rpuenc"
libaribb24_decoder_deps="libaribb24"
libaribcaption_decoder_deps="libaribcaption"
libcelt_decoder_deps="libcelt"
libcodec2_decoder_deps="libcodec2"
libcodec2_encoder_deps="libcodec2"
libdav1d_decoder_deps="libdav1d"
libdav1d_decoder_select="atsc_a53 dovi_rpudec"
libdavs2_decoder_deps="libdavs2"
libdavs2_decoder_select="avs2_parser"
libfdk_aac_decoder_deps="libfdk_aac"
libfdk_aac_encoder_deps="libfdk_aac"
libfdk_aac_encoder_select="audio_frame_queue"
libgme_demuxer_deps="libgme"
libgsm_decoder_deps="libgsm"
libgsm_encoder_deps="libgsm"
libgsm_ms_decoder_deps="libgsm"
libgsm_ms_encoder_deps="libgsm"
libilbc_decoder_deps="libilbc"
libilbc_encoder_deps="libilbc"
libjxl_anim_decoder_deps="libjxl libjxl_threads"
libjxl_anim_encoder_deps="libjxl libjxl_threads"
libjxl_decoder_deps="libjxl libjxl_threads"
libjxl_encoder_deps="libjxl libjxl_threads"
libkvazaar_encoder_deps="libkvazaar"
liblc3_decoder_deps="liblc3"
liblc3_encoder_deps="liblc3"
liblc3_encoder_select="audio_frame_queue"
libmodplug_demuxer_deps="libmodplug"
libmp3lame_encoder_deps="libmp3lame"
libmp3lame_encoder_select="audio_frame_queue mpegaudioheader"
libmpeghdec_decoder_deps="libmpeghdec"
liboapv_encoder_deps="liboapv"
libopencore_amrnb_decoder_deps="libopencore_amrnb"
libopencore_amrnb_encoder_deps="libopencore_amrnb"
libopencore_amrnb_encoder_select="audio_frame_queue"
libopencore_amrwb_decoder_deps="libopencore_amrwb"
libopenh264_decoder_deps="libopenh264"
libopenh264_decoder_select="h264_mp4toannexb_bsf"
libopenh264_encoder_deps="libopenh264"
libopenjpeg_encoder_deps="libopenjpeg"
libopenmpt_demuxer_deps="libopenmpt"
libopus_decoder_deps="libopus"
libopus_encoder_deps="libopus"
libopus_encoder_select="audio_frame_queue"
librav1e_encoder_deps="librav1e"
librsvg_decoder_deps="librsvg"
libshine_encoder_deps="libshine"
libshine_encoder_select="audio_frame_queue mpegaudioheader"
libspeex_decoder_deps="libspeex"
libspeex_encoder_deps="libspeex"
libspeex_encoder_select="audio_frame_queue"
libsvtav1_encoder_deps="libsvtav1"
libsvtjpegxs_encoder_deps="libsvtjpegxs"
libsvtjpegxs_decoder_deps="libsvtjpegxs"
libsvtav1_encoder_select="dovi_rpuenc"
libtheora_encoder_deps="libtheora"
libtwolame_encoder_deps="libtwolame"
libuavs3d_decoder_deps="libuavs3d"
libvo_amrwbenc_encoder_deps="libvo_amrwbenc"
libvorbis_decoder_deps="libvorbis"
libvorbis_encoder_deps="libvorbis libvorbisenc"
libvorbis_encoder_select="audio_frame_queue"
libvpx_vp8_decoder_deps="libvpx"
libvpx_vp8_encoder_deps="libvpx"
libvpx_vp9_decoder_deps="libvpx"
libvpx_vp9_encoder_deps="libvpx"
libvvenc_encoder_deps="libvvenc"
libwebp_encoder_deps="libwebp"
libwebp_anim_encoder_deps="libwebp"
libx262_encoder_deps="libx262"
libx264_encoder_deps="libx264"
libx264_encoder_select="atsc_a53 golomb"
libx264rgb_encoder_deps="libx264"
libx264rgb_encoder_select="libx264_encoder"
libx265_encoder_deps="libx265"
libx265_encoder_select="atsc_a53 dovi_rpuenc"
libxavs_encoder_deps="libxavs"
libxavs2_encoder_deps="libxavs2"
libxevd_decoder_deps_any="libxevd libxevdb"
libxeve_encoder_deps_any="libxeve libxeveb"
libxvid_encoder_deps="libxvid"
libzvbi_teletext_decoder_deps="libzvbi"
vapoursynth_demuxer_deps="vapoursynth"
videotoolbox_suggest="coreservices"
videotoolbox_deps="corefoundation coremedia corevideo VTDecompressionSessionDecodeFrame"
videotoolbox_encoder_deps="videotoolbox VTCompressionSessionPrepareToEncodeFrames"

# demuxers / muxers
ac3_demuxer_select="ac3_parser"
act_demuxer_select="riffdec"
adts_muxer_select="mpeg4audio"
aiff_muxer_select="iso_media"
amv_muxer_select="riffenc"
apv_demuxer_select="apv_parser"
asf_demuxer_select="riffdec"
asf_o_demuxer_select="riffdec"
asf_muxer_select="riffenc"
asf_stream_muxer_select="asf_muxer"
av1_demuxer_select="av1_frame_merge_bsf av1_parser"
avi_demuxer_select="riffdec"
avi_muxer_select="riffenc"
avif_muxer_select="mov_muxer"
caf_demuxer_select="iso_media"
caf_muxer_select="iso_media"
dash_muxer_select="mp4_muxer"
dash_demuxer_deps="libxml2"
daud_muxer_select="pcm_rechunk_bsf"
dirac_demuxer_select="dirac_parser"
dts_demuxer_select="dca_parser"
dtshd_demuxer_select="dca_parser"
dv_demuxer_select="dvprofile"
dv_muxer_select="dvprofile"
dvdvideo_demuxer_select="mpegps_demuxer"
dvdvideo_demuxer_deps="libdvdnav libdvdread"
dxa_demuxer_select="riffdec"
eac3_demuxer_select="ac3_parser"
evc_demuxer_select="evc_frame_merge_bsf evc_parser"
f4v_muxer_select="mov_muxer"
fifo_muxer_deps="threads"
flac_demuxer_select="flac_parser"
flv_muxer_select="aac_adtstoasc_bsf iso_writer"
gxf_muxer_select="pcm_rechunk_bsf"
hds_muxer_select="flv_muxer"
hls_demuxer_select="aac_demuxer ac3_demuxer adts_header ac3_parser eac3_demuxer mov_demuxer mpegts_demuxer"
hls_muxer_select="mov_muxer mpegts_muxer webvtt_muxer"
hxvs_demuxer_select="h264_parser hevc_parser"
iamf_demuxer_select="iamfdec"
iamf_muxer_select="iamfenc"
image2_alias_pix_demuxer_select="image2_demuxer"
image2_brender_pix_demuxer_select="image2_demuxer"
imf_demuxer_deps="libxml2"
imf_demuxer_select="mxf_demuxer"
ipod_muxer_select="mov_muxer"
ismv_muxer_select="mov_muxer"
ivf_muxer_select="av1_metadata_bsf vp9_superframe_bsf"
latm_muxer_select="aac_adtstoasc_bsf mpeg4audio"
matroska_audio_muxer_select="matroska_muxer"
matroska_demuxer_select="riffdec"
matroska_demuxer_suggest="bzlib zlib"
matroska_muxer_select="iso_writer mpeg4audio riffenc aac_adtstoasc_bsf pgs_frame_merge_bsf vp9_superframe_bsf"
mcc_demuxer_select="smpte_436m"
mcc_muxer_select="smpte_436m"
mcc_muxer_suggest="eia608_to_smpte436m_bsf"
mlp_demuxer_select="mlp_parser"
mmf_muxer_select="riffenc"
mov_demuxer_select="iso_media riffdec"
mov_demuxer_suggest="iamfdec zlib"
mov_muxer_select="iso_media iso_writer riffenc rtpenc_chain vp9_superframe_bsf aac_adtstoasc_bsf ac3_parser"
mov_muxer_suggest="iamfenc"
mp3_demuxer_select="mpegaudio_parser"
mp3_muxer_select="mpegaudioheader"
mp4_muxer_select="mov_muxer"
mpegts_demuxer_select="iso_media"
mpegts_muxer_select="ac3_parser adts_muxer latm_muxer h264_mp4toannexb_bsf hevc_mp4toannexb_bsf vvc_mp4toannexb_bsf"
mpegtsraw_demuxer_select="mpegts_demuxer"
mxf_muxer_select="iso_writer pcm_rechunk_bsf rangecoder"
mxf_muxer_suggest="eia608_to_smpte436m_bsf"
mxf_d10_muxer_select="mxf_muxer"
mxf_opatom_muxer_select="mxf_muxer"
nut_muxer_select="riffenc"
nuv_demuxer_select="riffdec"
obu_demuxer_select="av1_frame_merge_bsf av1_parser"
obu_muxer_select="av1_metadata_bsf"
oga_muxer_select="ogg_muxer"
ogg_demuxer_select="dirac_parse"
ogv_muxer_select="ogg_muxer"
opus_muxer_select="ogg_muxer"
psp_muxer_select="mov_muxer"
rtp_demuxer_select="sdp_demuxer"
rtp_muxer_select="iso_writer"
rtp_mpegts_muxer_select="mpegts_muxer rtp_muxer"
rtpdec_select="asf_demuxer mov_demuxer mpegts_demuxer rm_demuxer rtp_protocol srtp"
rtsp_demuxer_select="http_protocol rtpdec"
rtsp_muxer_select="rtp_muxer http_protocol rtp_protocol rtpenc_chain"
sap_demuxer_select="sdp_demuxer"
sap_muxer_select="rtp_muxer rtp_protocol rtpenc_chain"
sdp_demuxer_select="rtpdec"
smoothstreaming_muxer_select="ismv_muxer"
spdif_demuxer_select="adts_header"
spdif_muxer_select="adts_header"
spx_muxer_select="ogg_muxer"
swf_demuxer_suggest="zlib"
tak_demuxer_select="tak_parser"
tee_muxer_select="fifo_muxer"
truehd_demuxer_select="mlp_parser"
tg2_muxer_select="mov_muxer"
tgp_muxer_select="mov_muxer"
vobsub_demuxer_select="mpegps_demuxer"
w64_demuxer_select="wav_demuxer"
w64_muxer_select="wav_muxer"
wav_demuxer_select="riffdec"
wav_muxer_select="riffenc"
webm_chunk_muxer_select="webm_muxer"
webm_dash_manifest_demuxer_select="matroska_demuxer"
whip_muxer_select="dtls_protocol rtp_muxer http_protocol"
wtv_demuxer_select="mpegts_demuxer riffdec"
wtv_muxer_select="mpegts_muxer riffenc"
xmv_demuxer_select="riffdec"
xwma_demuxer_select="riffdec"

# indevs / outdevs
android_camera_indev_deps="android camera2ndk mediandk pthreads"
alsa_indev_deps="alsa"
alsa_outdev_deps="alsa"
avfoundation_indev_deps="avfoundation corevideo coremedia pthreads AVCaptureSession"
avfoundation_indev_suggest="coregraphics applicationservices"
avfoundation_indev_extralibs="-framework Foundation"
audiotoolbox_outdev_deps="audiotoolbox pthreads AudioObjectPropertyAddress"
audiotoolbox_outdev_extralibs="-framework AudioToolbox -framework CoreAudio"
caca_outdev_deps="libcaca"
decklink_deps_any="libdl LoadLibrary"
decklink_indev_deps="decklink threads"
decklink_indev_extralibs="-lstdc++"
decklink_indev_suggest="libzvbi"
decklink_outdev_deps="decklink threads"
decklink_outdev_suggest="libklvanc"
decklink_outdev_extralibs="-lstdc++"
dshow_indev_deps="IBaseFilter"
dshow_indev_extralibs="-lpsapi -lole32 -lstrmiids -luuid -loleaut32 -lshlwapi"
fbdev_indev_deps="linux_fb_h"
fbdev_outdev_deps="linux_fb_h"
gdigrab_indev_deps="CreateDIBSection"
gdigrab_indev_extralibs="-lgdi32"
gdigrab_indev_select="bmp_decoder"
iec61883_indev_deps="libiec61883"
iec61883_indev_select="dv_demuxer"
jack_indev_deps="libjack"
jack_indev_deps_any="sem_timedwait dispatch_dispatch_h"
kmsgrab_indev_deps="libdrm"
lavfi_indev_deps="avfilter"
libcdio_indev_deps="libcdio"
libdc1394_indev_deps="libdc1394"
openal_indev_deps="openal"
oss_indev_deps_any="sys_soundcard_h"
oss_outdev_deps_any="sys_soundcard_h"
pulse_indev_deps="libpulse"
pulse_outdev_deps="libpulse"
sndio_indev_deps="sndio"
sndio_outdev_deps="sndio"
v4l2_indev_deps_any="linux_videodev2_h sys_videoio_h"
v4l2_indev_suggest="libv4l2"
v4l2_outdev_deps_any="linux_videodev2_h sys_videoio_h"
v4l2_outdev_suggest="libv4l2"
vfwcap_indev_deps="vfw32 vfwcap_defines"
xcbgrab_indev_deps="libxcb"
xcbgrab_indev_suggest="libxcb_shm libxcb_shape libxcb_xfixes"
xv_outdev_deps="xlib_xv xlib_x11 xlib_xext"

# protocols
android_content_protocol_deps="jni"
android_content_protocol_select="file_protocol"
async_protocol_deps="threads"
bluray_protocol_deps="libbluray"
ffrtmpcrypt_protocol_conflict="librtmp_protocol"
ffrtmpcrypt_protocol_deps_any="gcrypt gmp openssl mbedtls"
ffrtmpcrypt_protocol_select="tcp_protocol"
ffrtmphttp_protocol_conflict="librtmp_protocol"
ffrtmphttp_protocol_select="http_protocol"
ftp_protocol_select="tcp_protocol"
gopher_protocol_select="tcp_protocol"
gophers_protocol_select="tls_protocol"
http_protocol_select="tcp_protocol"
http_protocol_suggest="zlib"
httpproxy_protocol_select="tcp_protocol"
httpproxy_protocol_suggest="zlib"
https_protocol_select="tls_protocol"
https_protocol_suggest="zlib"
icecast_protocol_select="http_protocol"
mmsh_protocol_select="http_protocol"
mmst_protocol_select="network"
rtmp_protocol_conflict="librtmp_protocol"
rtmp_protocol_select="tcp_protocol"
rtmp_protocol_suggest="zlib"
rtmpe_protocol_select="ffrtmpcrypt_protocol"
rtmpe_protocol_suggest="zlib"
rtmps_protocol_conflict="librtmp_protocol"
rtmps_protocol_select="tls_protocol"
rtmps_protocol_suggest="zlib"
rtmpt_protocol_select="ffrtmphttp_protocol"
rtmpt_protocol_suggest="zlib"
rtmpte_protocol_select="ffrtmpcrypt_protocol ffrtmphttp_protocol"
rtmpte_protocol_suggest="zlib"
rtmpts_protocol_select="ffrtmphttp_protocol https_protocol"
rtmpts_protocol_suggest="zlib"
rtp_protocol_select="udp_protocol"
schannel_conflict="openssl gnutls libtls mbedtls"
sctp_protocol_deps="struct_sctp_event_subscribe struct_msghdr_msg_flags"
sctp_protocol_select="network"
securetransport_conflict="openssl gnutls libtls mbedtls"
srtp_protocol_select="rtp_protocol srtp"
tcp_protocol_select="network"
tls_protocol_deps_any="gnutls openssl schannel securetransport libtls mbedtls"
tls_protocol_select="tcp_protocol"
# TODO: Support libtls, mbedtls.
dtls_protocol_deps_any="openssl schannel gnutls"
dtls_protocol_select="udp_protocol"
udp_protocol_select="network"
udplite_protocol_select="network"
unix_protocol_deps="sys_un_h"
unix_protocol_select="network"
ipfs_gateway_protocol_select="https_protocol"
ipns_gateway_protocol_select="https_protocol"


# filters
ametadata_filter_deps="avformat"
amovie_filter_deps="avcodec avformat"
aresample_filter_deps="swresample"
asr_filter_deps="pocketsphinx"
ass_filter_deps="libass"
avgblur_opencl_filter_deps="opencl"
avgblur_vulkan_filter_deps="vulkan spirv_compiler"
azmq_filter_deps="libzmq"
blackdetect_vulkan_filter_deps="vulkan spirv_library"
blackframe_filter_deps="gpl"
blend_vulkan_filter_deps="vulkan spirv_library"
boxblur_filter_deps="gpl"
boxblur_opencl_filter_deps="opencl gpl"
bs2b_filter_deps="libbs2b"
bwdif_cuda_filter_deps="ffnvcodec"
bwdif_cuda_filter_deps_any="cuda_nvcc cuda_llvm"
bwdif_vulkan_filter_deps="vulkan spirv_compiler"
chromaber_vulkan_filter_deps="vulkan spirv_library"
color_vulkan_filter_deps="vulkan spirv_library"
colorkey_opencl_filter_deps="opencl"
colormatrix_filter_deps="gpl"
convolution_opencl_filter_deps="opencl"
coreimage_filter_deps="coreimage appkit"
coreimage_filter_extralibs="-framework OpenGL"
coreimagesrc_filter_deps="coreimage appkit"
coreimagesrc_filter_extralibs="-framework OpenGL"
cover_rect_filter_deps="avcodec avformat gpl"
cropdetect_filter_deps="gpl"
deinterlace_qsv_filter_deps="libmfx"
deinterlace_qsv_filter_select="qsvvpp"
deinterlace_vaapi_filter_deps="vaapi"
delogo_filter_deps="gpl"
denoise_vaapi_filter_deps="vaapi"
derain_filter_select="dnn"
deshake_filter_select="pixelutils"
deshake_opencl_filter_deps="opencl"
dilation_opencl_filter_deps="opencl"
dnn_classify_filter_select="dnn"
dnn_detect_filter_select="dnn"
dnn_processing_filter_select="dnn"
drawtext_filter_deps="libfreetype libharfbuzz"
drawtext_filter_suggest="libfontconfig libfribidi"
drawvg_filter_deps="cairo"
elbg_filter_deps="avcodec"
eq_filter_deps="gpl"
erosion_opencl_filter_deps="opencl"
find_rect_filter_deps="avcodec avformat gpl"
flip_vulkan_filter_deps="vulkan spirv_library"
flite_filter_deps="libflite threads"
framerate_filter_select="scene_sad"
freezedetect_filter_select="scene_sad"
frei0r_deps_any="libdl LoadLibrary"
frei0r_filter_deps="frei0r"
frei0r_src_filter_deps="frei0r"
fspp_filter_deps="gpl"
fsync_filter_deps="avformat"
gblur_vulkan_filter_deps="vulkan spirv_library"
hflip_vulkan_filter_deps="vulkan spirv_library"
histeq_filter_deps="gpl"
hqdn3d_filter_deps="gpl"
iccdetect_filter_deps="lcms2"
iccgen_filter_deps="lcms2"
identity_filter_select="scene_sad"
interlace_filter_deps="gpl"
interlace_vulkan_filter_deps="vulkan spirv_library"
kerndeint_filter_deps="gpl"
ladspa_filter_deps="ladspa libdl"
lcevc_filter_deps="liblcevc_dec"
lensfun_filter_deps="liblensfun version3"
libplacebo_filter_deps="libplacebo vulkan"
lv2_filter_deps="lv2"
mcdeint_filter_deps="avcodec gpl"
metadata_filter_deps="avformat"
movie_filter_deps="avcodec avformat"
mpdecimate_filter_deps="gpl"
mpdecimate_filter_select="pixelutils"
minterpolate_filter_select="scene_sad"
mptestsrc_filter_deps="gpl"
msad_filter_select="scene_sad"
negate_filter_deps="lut_filter"
nlmeans_opencl_filter_deps="opencl"
nlmeans_vulkan_filter_deps="vulkan spirv_library"
nnedi_filter_deps="gpl"
ocr_filter_deps="libtesseract"
ocv_filter_deps="libopencv"
openclsrc_filter_deps="opencl"
qrencode_filter_deps="libqrencode"
qrencodesrc_filter_deps="libqrencode"
quirc_filter_deps="libquirc"
ocio_filter_deps="libopencolorio"
libopencolorio_filter_deps="libopencolorio"
overlay_opencl_filter_deps="opencl"
overlay_qsv_filter_deps="libmfx"
overlay_qsv_filter_select="qsvvpp"
overlay_vaapi_filter_deps="vaapi VAProcPipelineCaps_blend_flags"
overlay_vulkan_filter_deps="vulkan spirv_library"
owdenoise_filter_deps="gpl"
pad_opencl_filter_deps="opencl"
pan_filter_deps="swresample"
perspective_filter_deps="gpl"
phase_filter_deps="gpl"
pp7_filter_deps="gpl"
prewitt_opencl_filter_deps="opencl"
procamp_vaapi_filter_deps="vaapi"
program_opencl_filter_deps="opencl"
pullup_filter_deps="gpl"
remap_opencl_filter_deps="opencl"
removelogo_filter_deps="avcodec avformat swscale"
repeatfields_filter_deps="gpl"
roberts_opencl_filter_deps="opencl"
rubberband_filter_deps="librubberband"
sab_filter_deps="gpl swscale"
scale2ref_filter_deps="swscale"
scale_filter_deps="swscale"
sr_amf_filter_deps="amf"
vpp_amf_filter_deps="amf"
scale_qsv_filter_deps="libmfx"
scale_qsv_filter_select="qsvvpp"
scdet_filter_select="scene_sad"
scdet_vulkan_filter_deps="vulkan spirv_library"
select_filter_select="scene_sad"
sharpness_vaapi_filter_deps="vaapi"
showcqt_filter_deps="avformat swscale"
showcqt_filter_suggest="libfontconfig libfreetype"
signature_filter_deps="gpl avcodec avformat"
smartblur_filter_deps="gpl"
sobel_opencl_filter_deps="opencl"
sofalizer_filter_deps="libmysofa"
spp_filter_deps="gpl avcodec"
spp_filter_select="idctdsp fdctdsp me_cmp pixblockdsp"
sr_filter_deps="avformat swscale"
sr_filter_select="dnn"
stereo3d_filter_deps="gpl"
subtitles_filter_deps="avformat avcodec libass"
super2xsai_filter_deps="gpl"
pixfmts_super2xsai_test_deps="super2xsai_filter"
tinterlace_filter_deps="gpl"
tinterlace_merge_test_deps="tinterlace_filter"
tinterlace_pad_test_deps="tinterlace_filter"
tonemap_filter_deps="const_nan"
tonemap_vaapi_filter_deps="vaapi VAProcFilterParameterBufferHDRToneMapping"
tonemap_opencl_filter_deps="opencl const_nan"
transpose_opencl_filter_deps="opencl"
transpose_vaapi_filter_deps="vaapi VAProcPipelineCaps_rotation_flags"
transpose_vt_filter_deps="videotoolbox VTPixelRotationSessionCreate"
transpose_vulkan_filter_deps="vulkan spirv_library"
unsharp_opencl_filter_deps="opencl"
uspp_filter_deps="gpl avcodec"
vaguedenoiser_filter_deps="gpl"
vflip_vulkan_filter_deps="vulkan spirv_library"
vidstabdetect_filter_deps="libvidstab"
vidstabtransform_filter_deps="libvidstab"
libvmaf_filter_deps="libvmaf"
libvmaf_cuda_filter_deps="libvmaf libvmaf_cuda ffnvcodec"
zmq_filter_deps="libzmq"
zoompan_filter_deps="swscale"
zscale_filter_deps="libzimg const_nan"
scale_vaapi_filter_deps="vaapi"
scale_vt_filter_deps="videotoolbox VTPixelTransferSessionCreate"
scale_vulkan_filter_deps="vulkan spirv_compiler spirv_library"
vpp_qsv_filter_deps="libmfx"
vpp_qsv_filter_select="qsvvpp"
xfade_opencl_filter_deps="opencl"
xfade_vulkan_filter_deps="vulkan spirv_library"
yadif_cuda_filter_deps="ffnvcodec"
yadif_cuda_filter_deps_any="cuda_nvcc cuda_llvm"
yadif_videotoolbox_filter_deps="metal corevideo videotoolbox"
hstack_vaapi_filter_deps="vaapi_1"
vstack_vaapi_filter_deps="vaapi_1"
xstack_vaapi_filter_deps="vaapi_1"
hstack_qsv_filter_deps="libmfx"
hstack_qsv_filter_select="qsvvpp"
vstack_qsv_filter_deps="libmfx"
vstack_qsv_filter_select="qsvvpp"
xstack_qsv_filter_deps="libmfx"
xstack_qsv_filter_select="qsvvpp"
pad_vaapi_filter_deps="vaapi_1"
drawbox_vaapi_filter_deps="vaapi_1"
whisper_filter_deps="whisper"

# examples
avio_http_serve_files_deps="avformat avutil fork"
avio_list_dir_deps="avformat avutil"
avio_read_callback_deps="avformat avcodec avutil"
decode_audio_example_deps="avcodec avutil"
decode_filter_audio_example_deps="avfilter avcodec avformat avutil"
decode_filter_video_example_deps="avfilter avcodec avformat avutil"
decode_video_example_deps="avcodec avutil"
demux_decode_example_deps="avcodec avformat avutil"
encode_audio_example_deps="avcodec avutil"
encode_video_example_deps="avcodec avutil"
extract_mvs_example_deps="avcodec avformat avutil"
filter_audio_example_deps="avfilter avutil"
hw_decode_example_deps="avcodec avformat avutil"
mux_example_deps="avcodec avformat avutil swscale"
qsv_decode_example_deps="avcodec avutil libmfx h264_qsv_decoder"
remux_example_deps="avcodec avformat avutil"
resample_audio_example_deps="avutil swresample"
scale_video_example_deps="avutil swscale"
show_metadata_example_deps="avformat avutil"
transcode_aac_example_deps="avcodec avformat swresample"
transcode_example_deps="avfilter avcodec avformat avutil"
vaapi_encode_example_deps="avcodec avutil h264_vaapi_encoder"
vaapi_transcode_example_deps="avcodec avformat avutil h264_vaapi_encoder"
qsv_transcode_example_deps="avcodec avformat avutil h264_qsv_encoder"

# EXTRALIBS_LIST
cpu_init_extralibs="pthreads_extralibs"
cws2fws_extralibs="zlib_extralibs"

# libraries, in any order
avcodec_deps="avutil"
avcodec_suggest="libm stdatomic zlib spirv_library"
avdevice_deps="avformat avcodec avutil"
avdevice_suggest="libm stdatomic"
avfilter_deps="avutil"
avfilter_suggest="libm stdatomic zlib spirv_library"
avformat_deps="avcodec avutil"
avformat_suggest="libm network zlib stdatomic"
avutil_suggest="clock_gettime ffnvcodec gcrypt libm zlib libdrm libmfx opencl openssl user32 vaapi vulkan videotoolbox corefoundation corevideo coremedia bcrypt stdatomic"
swresample_deps="avutil"
swresample_suggest="libm libsoxr stdatomic"
swscale_deps="avutil"
swscale_suggest="libm stdatomic"
shader_compression_suggest="zlib"

avcodec_extralibs="pthreads_extralibs iconv_extralibs dxva2_extralibs liblcevc_dec_extralibs lcms2_extralibs"
avfilter_extralibs="pthreads_extralibs"
avutil_extralibs="d3d11va_extralibs d3d12va_extralibs mediacodec_extralibs nanosleep_extralibs pthreads_extralibs vaapi_drm_extralibs vaapi_x11_extralibs vaapi_win32_extralibs vdpau_x11_extralibs"

# programs
ffmpeg_deps="avcodec avfilter avformat threads"
ffmpeg_select="aformat_filter anull_filter atrim_filter crop_filter
               format_filter hflip_filter null_filter rotate_filter
               transpose_filter trim_filter vflip_filter"
ffmpeg_suggest="ole32 psapi shell32"
ffplay_deps="avcodec avformat avfilter swscale swresample sdl2"
ffplay_select="crop_filter transpose_filter hflip_filter vflip_filter rotate_filter"
ffplay_suggest="shell32 libplacebo vulkan"
ffprobe_deps="avcodec avformat"
ffprobe_suggest="shell32"

# documentation
podpages_deps="perl"
manpages_deps="perl pod2man"
htmlpages_deps="perl"
htmlpages_deps_any="makeinfo_html texi2html"
txtpages_deps="perl makeinfo"
doc_deps_any="manpages htmlpages podpages txtpages"

# default parameters

logfile="ffbuild/config.log"

# installation paths
prefix_default="/usr/local"
bindir_default='${prefix}/bin'
datadir_default='${prefix}/share/ffmpeg'
docdir_default='${prefix}/share/doc/ffmpeg'
incdir_default='${prefix}/include'
libdir_default='${prefix}/lib'
mandir_default='${prefix}/share/man'

# toolchain
ar_default="ar"
cc_default="gcc"
stdc_default="c17"
stdcxx_default="c++17"
cxx_default="g++"
host_cc_default="gcc"
doxygen_default="doxygen"
install="install"
ln_s_default="ln -s -f"
glslc_default="glslc"
metalcc_default="xcrun -sdk macosx metal"
metallib_default="xcrun -sdk macosx metallib"
nm_default="nm -g"
pkg_config_default=pkg-config
ranlib_default="ranlib"
strip_default="strip"
version_script='--version-script'
objformat="elf32"
x86asmexe_default="nasm"
windres_default="windres"
striptype="direct"
response_files_default="auto"

# OS
target_os_default=$(tolower $(uname -s))
host_os=$target_os_default

# machine
if test "$target_os_default" = aix; then
    arch_default=$(uname -p)
    strip_default="strip -X32_64"
    nm_default="nm -g -X32_64"
elif test "$MSYSTEM_CARCH" != ""; then
    arch_default="$MSYSTEM_CARCH"
else
    arch_default=$(uname -m)
fi
cpu="generic"
intrinsics="none"

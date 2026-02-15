# ffplay object sources.
# Used by fftools/Makefile and ffbuild/generate_cmakes.sh (via makefile_to_cmake).
OBJS-ffplay += \
    cmdutils.o \
    opt_common.o \
    ffplay.o \
    ffplay_renderer.o \

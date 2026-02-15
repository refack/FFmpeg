# ffprobe object sources.
# Used by fftools/Makefile and ffbuild/generate_cmakes.sh (via makefile_to_cmake).
OBJS-ffprobe +=                       \
    cmdutils.o                \
    opt_common.o              \
    ffprobe.o                 \
    textformat/avtextformat.o \
    textformat/tf_compact.o   \
    textformat/tf_default.o   \
    textformat/tf_flat.o      \
    textformat/tf_ini.o       \
    textformat/tf_json.o      \
    textformat/tf_mermaid.o   \
    textformat/tf_xml.o       \
    textformat/tw_avio.o      \
    textformat/tw_buffer.o    \
    textformat/tw_stdout.o    \

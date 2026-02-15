# ffmpeg object sources.
# Used by fftools/Makefile and ffbuild/generate_cmakes.sh (via makefile_to_cmake).
OBJS-ffmpeg +=                  \
    cmdutils.o          \
    opt_common.o        \
    ffmpeg.o            \
    ffmpeg_dec.o        \
    ffmpeg_demux.o      \
    ffmpeg_enc.o        \
    ffmpeg_filter.o     \
    ffmpeg_hw.o         \
    ffmpeg_mux.o        \
    ffmpeg_mux_init.o   \
    ffmpeg_opt.o        \
    ffmpeg_sched.o      \
    graph/graphprint.o        \
    sync_queue.o        \
    thread_queue.o      \
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
    resources/resman.o        \
    $(RESOBJS)                        \


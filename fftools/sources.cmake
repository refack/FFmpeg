# Processed include: fftools/resources/Makefile
# Skipping target specific assignment: OBJS-resman +=                      fftools/resources/resman.o
# Skipping target specific assignment: OBJS-ffmpeg +=                   fftools/ffmpeg_dec.o         fftools/ffmpeg_demux.o       fftools/ffmpeg_enc.o         fftools/ffmpeg_filter.o      fftools/ffmpeg_hw.o          fftools/ffmpeg_mux.o         fftools/ffmpeg_mux_init.o    fftools/ffmpeg_opt.o         fftools/ffmpeg_sched.o       fftools/graph/graphprint.o         fftools/sync_queue.o         fftools/thread_queue.o       fftools/textformat/avtextformat.o  fftools/textformat/tf_compact.o    fftools/textformat/tf_default.o    fftools/textformat/tf_flat.o       fftools/textformat/tf_ini.o        fftools/textformat/tf_json.o       fftools/textformat/tf_mermaid.o    fftools/textformat/tf_xml.o        fftools/textformat/tw_avio.o       fftools/textformat/tw_buffer.o     fftools/textformat/tw_stdout.o     $(OBJS-resman)                     $(RESOBJS)
# Skipping target specific assignment: OBJS-ffprobe +=                        fftools/textformat/avtextformat.o  fftools/textformat/tf_compact.o    fftools/textformat/tf_default.o    fftools/textformat/tf_flat.o       fftools/textformat/tf_ini.o        fftools/textformat/tf_json.o       fftools/textformat/tf_mermaid.o    fftools/textformat/tf_xml.o        fftools/textformat/tw_avio.o       fftools/textformat/tw_buffer.o     fftools/textformat/tw_stdout.o
# Skipping target specific assignment: OBJS-ffmpeg += $(COMPAT_OBJS:%=compat/%)
# Skipping target specific assignment: OBJS-ffplay += fftools/ffplay_renderer.o
# Warning: Unexpanded variable in file list: fftools/$(1).c
# Warning: Unexpanded variable in file list: $(OBJS-$(1)-yes)
if(1)
    list(APPEND FFTOOLS_SOURCES fftools/cmdutils.c)
    list(APPEND FFTOOLS_SOURCES fftools/opt_common.c)
endif()
if(1)
    list(APPEND FFTOOLS_SOURCES fftools/fftoolsres.c)
endif()

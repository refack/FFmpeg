AVPROGS-$(CONFIG_FFMPEG)   += ffmpeg
AVPROGS-$(CONFIG_FFPLAY)   += ffplay
AVPROGS-$(CONFIG_FFPROBE)  += ffprobe

# Expand enabled programs into final output names.
AVPROGS     := $(AVPROGS-yes:%=%$(PROGSSUF)$(EXESUF))
PROGS       += $(AVPROGS)

# Basenames used for install/uninstall targets.
AVBASENAMES  = ffmpeg ffplay ffprobe
ALLAVPROGS   = $(AVBASENAMES:%=%$(PROGSSUF)$(EXESUF))
ALLAVPROGS_G = $(AVBASENAMES:%=%$(PROGSSUF)_g$(EXESUF))

include $(SRC_PATH)/fftools/resources/Makefile

# Tool source lists are transcluded for easier maintenance.
include $(SRC_PATH)/fftools/ffmpeg.sourcelist.mak
include $(SRC_PATH)/fftools/ffprobe.sourcelist.mak
include $(SRC_PATH)/fftools/ffplay.sourcelist.mak

# Common compatibility sources for ffmpeg.
OBJS-ffmpeg += $(COMPAT_OBJS:%=compat/%)

# Define per-tool object lists and build rules.
define DEF_FFTOOL_RULES
  OBJS-$(1) += $(OBJS-$(1)-yes)
  ifdef HAVE_GNU_WINDRES
  OBJS-$(1) += fftools/fftoolsres.o
  endif
  $(1)$(PROGSSUF)_g$(EXESUF): $$(OBJS-$(1))
  $$(OBJS-$(1)): | fftools fftools/textformat fftools/resources fftools/graph
  $$(OBJS-$(1)): CFLAGS  += $(CFLAGS-$(1))
  $(1)$(PROGSSUF)_g$(EXESUF): LDFLAGS += $(LDFLAGS-$(1))
  $(1)$(PROGSSUF)_g$(EXESUF): FF_EXTRALIBS += $(EXTRALIBS-$(1))
  -include $$(OBJS-$(1):.o=.d)
endef

$(foreach P,$(AVPROGS-yes),$(eval $(call DEF_FFTOOL_RULES,$(P))))

all: $(AVPROGS)

fftools/ffprobe.o fftools/cmdutils.o: libavutil/ffversion.h | fftools
OUTDIRS += fftools
OUTDIRS += fftools/textformat
OUTDIRS += fftools/resources
OUTDIRS += fftools/graph

ifdef AVPROGS
install: install-progs install-data
endif

install-progs-yes:
install-progs-$(CONFIG_SHARED): install-libs

install-progs: install-progs-yes $(AVPROGS)
	$(Q)mkdir -p "$(BINDIR)"
	$(INSTALL) -c -m 755 $(AVPROGS) "$(BINDIR)"

uninstall: uninstall-progs

uninstall-progs:
	$(RM) $(addprefix "$(BINDIR)/", $(ALLAVPROGS))

clean::
	$(RM) $(ALLAVPROGS) $(ALLAVPROGS_G) $(CLEANSUFFIXES:%=fftools/%) $(CLEANSUFFIXES:%=fftools/graph/%) $(CLEANSUFFIXES:%=fftools/textformat/%)

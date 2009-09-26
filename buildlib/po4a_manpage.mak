# -*- make -*-

# This handles man pages with po4a. We convert to the respective
# output in the source directory then copy over to the final dest. This
# means po4a is only needed if compiling from bzr

# Input
# $(LC)     - The language code of the translation

# See defaults.mak for information about LOCAL

# generate a list of accepted man page translations
SOURCE = $(patsubst %.xml,%,$(wildcard *.$(LC).?.xml))
INCLUDES = apt.ent

# Do not use XMLTO, build the manpages directly with XSLTPROC
ifdef XSLTPROC

STYLESHEET=../manpage-style.xsl

LOCAL := po4a-manpage-$(firstword $(SOURCE))
$(LOCAL)-LIST := $(SOURCE)

# Install generation hooks
doc: $($(LOCAL)-LIST)
veryclean: veryclean/$(LOCAL)

$($(LOCAL)-LIST) :: % : %.xml $(INCLUDES)
	echo Creating man page $@
	$(XSLTPROC) -o $@ $(STYLESHEET) $< # why xsltproc doesn't respect the -o flag here???
	mv -f $(subst .$(LC),,$@) $@

# Clean rule
.PHONY: veryclean/$(LOCAL)
veryclean/$(LOCAL):
	-rm -rf $($(@F)-LIST) apt.ent apt.$(LC).8 \
		$(addsuffix .xml,$($(@F)-LIST))

HAVE_PO4A=yes
endif

# take care of the rest
SOURCE := $(SOURCE) apt.$(LC).8
INCLUDES :=

ifndef HAVE_PO4A
# Strip from the source list any man pages we dont have compiled already
SOURCE := $(wildcard $(SOURCE))
endif

# Chain to the manpage rule
ifneq ($(words $(SOURCE)),0)
include $(MANPAGE_H)
endif
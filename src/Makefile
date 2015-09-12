########################################################################
#                                                                      #
#                    Makefile for Genomon-fusion                       #
#                                                                      #
########################################################################


TARGET=GFKalign GFKdedup GFKdetect GFKalign-dedup

CC = mpifccpx
CFLAGS = -Xg -Kfast -Kopenmp -D_GNU_SOURCE

ifneq (,$(findstring greatwave,$(HOSTNAME)))
# HOKUSAI FX100
  CFLAGS += -DCHDIR
  INSTDIR = ../bin
  SHAREDDIR = ../shared
else
  INSTDIR = ..
  SHAREDDIR = ..
endif

all: $(TARGET)

.PRECIOUS: %.c
.SUFFIXES: .c .template

.template.c:
	sed -e "s%GFKDIR%${INSTDIR}%g" \
	    -e "s%SHAREDDIR%${SHAREDDIR}%g" $< > $@

%: %.c
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f *.c

distclean: clean
	rm -f $(TARGET)

install: $(TARGET)
	cp -f $^ ../bin/

$(TARGET): my_timing.h

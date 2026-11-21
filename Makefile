CFLAGS ?= -O2 -g -Wall
PW := examples/official/pipewire
MAN := examples/official/manpages
PW_CFLAGS = $(shell pkg-config --cflags libpipewire-0.3)
PW_LIBS = $(shell pkg-config --libs libpipewire-0.3) -lm

PW_BINS := $(addprefix build/,tutorial1 tutorial2 tutorial3 tutorial4 audio-capture)
MAN_BINS := $(addprefix build/,pshm_ucase_bounce pshm_ucase_send seccomp)

all: pipewire manpages
pipewire: $(PW_BINS)
manpages: $(MAN_BINS)

build/%: $(PW)/%.c | build
	$(CC) $(CFLAGS) $(PW_CFLAGS) $< -o $@ $(PW_LIBS)

build/%: $(MAN)/%.c | build
	$(CC) $(CFLAGS) $< -o $@

build:
	mkdir -p build

clean:
	rm -rf build

.PHONY: all pipewire manpages clean

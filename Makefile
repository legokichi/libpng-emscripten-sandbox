PNGFLAGS = $(shell pkg-config libpng --cflags)
PNGLIBS = $(shell pkg-config libpng --libs)
CC = gcc -std=c11
LD = gcc
CFLAGS = -Wall -O0
LDFLAGS =
INCLUDE = -I./include
ODIR = ./obj
SDIR = ./src
DIST = ./bin
SRCS = $(wildcard ./src/*.c)
OBJS = $(SRCS:./src/%.c=./obj/%.o)
TARGET = $(DIST)/a.out
EMCC = emcc -std=c11
EMLD = emcc
EMFLAGS = -Wall -O0 #-s EXPORTED_FUNCTIONS="['open_png_file']" #-s ALLOW_MEMORY_GROWTH=1 -O3 -g3 --js-opts 1 --closure 2
EMLDFLAGS = --pre-js ./src/em-pre.js --post-js ./src/em-post.js # -shared --memory-init-file 0  -s EXPORTED_FUNCTIONS=$(EXPORTED_FUNCTIONS) -s ALLOW_MEMORY_GROWTH=1
EMPNGFLAGS = -I./lib/libpng-1.6.18
EMPNGLIBS = -L./lib/libpng-1.6.18
LLBCS = $(SRCS:./src/%.c=./obj/%.bc)

all : $(TARGET)

$(TARGET): $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) -o $@ $^ $(PNGLIBS) $(LDFLAGS)

$(ODIR)/%.o: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(CC) $(CFLAGS) $(PNGFLAGS) $(INCLUDE) -o $@ -c $<

debug: CFLAGS = -O1 -g
debug: all

run:
	./bin/a.out chirp_qi.png

emcc: $(TARGET).js

$(TARGET).js: $(LLBCS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(EMLD) -o $@ $^ $(EMPNGLIBS) $(EMLDFLAGS)

$(ODIR)/%.bc: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(EMCC) $(EMFLAGS) $(EMPNGFLAGS) $(INCLUDE) -o $@ -c $<

debugjs: EMFLAGS = -O1 -g -s INLINING_LIMIT=10
debugjs: asmjs

runjs:
	node ./bin/a.out.js ../test.png



.PHONY: clean
clean:
	rm -rf $(ODIR) $(DIST)

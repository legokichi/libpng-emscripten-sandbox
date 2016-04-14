INCLUDE = -I./include $(shell pkg-config libpng --cflags) $(shell pkg-config libpng --libs)
CFLAGS = -Wall -O0
CC = gcc -std=c11
LD = gcc
LDFLAGS =
ODIR = ./obj
SDIR = ./src
DIST = ./bin
SRCS = $(wildcard ./src/*.c)
OBJS = $(SRCS:./src/%.c=./obj/%.o)
TARGET = $(DIST)/a.out


emcc: CC = emcc -std=c11
emcc: FLAGS = -Wall -O1
emcc: INCLUDE = -I./include -I./zlib-1.2.8 -I./libpng-1.6.21
emcc: LD = emcc -O1
emcc: LDFLAGS = --pre-js ./src/em-pre.js --post-js ./src/em-post.js -s EXPORTED_FUNCTIONS="['_main', '_open_png_file']" ./zlib-1.2.8/libz.bc ./libpng-1.6.21/.libs/libpng16.16.bc  # -shared --memory-init-file 0 -s ALLOW_MEMORY_GROWTH=1 -O3 -g3 --js-opts 1 --closure 2
emcc: $(TARGET).js

$(TARGET).js: $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) -o $@ $(LDFLAGS) $^

all: $(TARGET)

$(TARGET): $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) -o $@ $(LDFLAGS) $^

$(ODIR)/%.o: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(CC) -o $@ $(CFLAGS) $(INCLUDE) -c $<

debug: CFLAGS = $(CFLAGS) -O1 -g
debug: all

debugjs: CFLAGS = $(CFLAGS) -O1 -g -s INLINING_LIMIT=10
debugjs: asmjs

run:
	./bin/a.out chirp_qi.png

runjs:
	node ./bin/a.out.js ../test.png

runbrowser:
	http-server ./

# clean

.PHONY: clean
clean:
	rm -rf $(ODIR)/* $(DIST)/*

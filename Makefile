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

wasm: LDFLAGS = -s BINARYEN=1 -s BINARYEN_METHOD='..'
wasm: asmjs


asmjs: CC = emcc -std=c11 -O1 --llvm-opts 0
asmjs: FLAGS = -Wall -Demscripten=true
asmjs: INCLUDE = -I./include -I./zlib-1.2.8 -I./libpng-1.6.21
asmjs: LD = emcc -O1 --llvm-lto 0 -Demscripten=true 
asmjs: LDFLAGS += --pre-js ./src/em-pre.js --post-js ./src/em-post.js -s EXCEPTION_DEBUG=1 -s ASSERTIONS=1 -s EXPORTED_FUNCTIONS="['_open_png_file']" ./zlib-1.2.8/libz.bc ./libpng-1.6.21/.libs/libpng16.16.bc # -shared --memory-init-file 0 -s ALLOW_MEMORY_GROWTH=1 -O3 -g3 --js-opts 1 --closure 2
asmjs: $(TARGET).js

$(TARGET).js: $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) -o $@ $(INCLUDE) $(LDFLAGS) $^

all: $(TARGET)

$(TARGET): $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) -o $@ $(INCLUDE) $(LDFLAGS) $^

$(ODIR)/%.o: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(CC) -o $@ $(CFLAGS) $(INCLUDE) -c $<

debug: CFLAGS = $(CFLAGS) -O1 -g
debug: all

debugjs: CFLAGS = $(CFLAGS) -O1 -g -s INLINING_LIMIT=10 -s EXCEPTION_DEBUG=1 -s ASSERTIONS=1
debugjs: asmjs

run:
	./bin/a.out chirp_qi.png

runjs:
	node ./bin/a.out.js ../chirp_qi.png

runbrowser:
	http-server ./

# clean

.PHONY: clean
clean:
	rm -rf $(ODIR)/* $(DIST)/*

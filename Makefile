# include
ZLIBFLAGS = -I./zlib-1.2.8
ZLIBLIBS = -L./zlib-1.2.8
PNGFLAGS = -I./libpng-1.6.21 -I./libpng-1.6.21/png.c #$(shell pkg-config libpng --cflags)
PNGLIBS = -L./libpng-1.6.21 #$(shell pkg-config libpng --libs)
FLAGS = $(ZLIBFLAGS) $(PNGFLAGS)
LIBS = $(ZLIBLIBS) $(PNGLIBS)
INCLUDE = -I./include $(FLAGS) $(LIBS)
# compiler and linker
CFLAGS = -Wall -O0
EMFLAGS = -Wall -O1 -s EXPORTED_FUNCTIONS="['_main', '_open_png_file']" #-s ALLOW_MEMORY_GROWTH=1 -O3 -g3 --js-opts 1 --closure 2
## -O1 is asm.js
CC = gcc -std=c11 # gnu c compiler or clang
EMCC = emcc -std=c11 # compiler
LD = gcc # linker
EMLD = emcc # linker
LDFLAGS =
EMLDFLAGS = --pre-js ./src/em-pre.js --post-js ./src/em-post.js # -shared --memory-init-file 0  -s EXPORTED_FUNCTIONS=$(EXPORTED_FUNCTIONS) -s ALLOW_MEMORY_GROWTH=1
# make setting
ODIR = ./obj
SDIR = ./src
DIST = ./bin
SRCS = $(wildcard ./src/*.c)
OBJS = $(SRCS:./src/%.c=./obj/%.o)
TARGET = $(DIST)/a.out
LLBCS = $(SRCS:./src/%.c=./obj/%.bc) # llvm byte code


# normal compile

all : $(TARGET)

$(TARGET): $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) -o $@ $^ $(INCLUDE) $(LDFLAGS)

$(ODIR)/%.o: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ -c $<

debug: CFLAGS = $(CFLAGS) -O1 -g
debug: all

run:
	./bin/a.out chirp_qi.png


# emscripten compile

emcc: $(TARGET).js

$(TARGET).js: $(LLBCS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(EMLD) -o $@ $^ $(INCLUDE) $(EMLDFLAGS)

$(ODIR)/%.bc: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(EMCC) $(EMFLAGS) $(INCLUDE) -o $@ -c $<

debugjs: EMFLAGS = -O1 -g -s INLINING_LIMIT=10
debugjs: asmjs

runjs:
	node ./bin/a.out.js ../test.png

runbrowser:
	http-server ./




# clean

.PHONY: clean
clean:
	rm -rf $(ODIR) $(DIST)

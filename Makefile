# include
ZLIBFLAGS = -I./zlib-1.2.8
PNGFLAGS = -I./libpng-1.6.21
INCLUDE = -I./include $(ZLIBFLAGS) $(PNGFLAGS)
# compiler and linker
CFLAGS = -Wall -O0
EMCCFLAGS = -Wall -O1 -s EXPORTED_FUNCTIONS="['_main', '_open_png_file']" #-s ALLOW_MEMORY_GROWTH=1 -O3 -g3 --js-opts 1 --closure 2
## -O1 is asm.js
CC = gcc -std=c11 # gnu c compiler or clang
EMCC = emcc -std=c11 # compiler
LD = gcc # linker
EMLD = emcc # linker
LDFLAGS =
EMLDFLAGS = --pre-js ./src/em-pre.js --post-js ./src/em-post.js # -shared --memory-init-file 0  -s EXPORTED_FUNCTIONS=$(EXPORTED_FUNCTIONS) -s ALLOW_MEMORY_GROWTH=1
ODIR = ./obj
SDIR = ./src
DIST = ./bin
SRCS = $(wildcard ./src/*.c)
OBJS = $(SRCS:./src/%.c=./obj/%.o)
TARGET = $(DIST)/a.out


emcc: CC = $(EMCC)
emcc: FLAGS = $(EMCCFLAGS)
emcc: LD = $(EMLD)
emcc: LDFLAGS = $(EMLDFLAGS)
emcc: INCLUDE = $()
emcc: OBJS = $(OBJS) ./zlib-1.2.8/libz.bc ./libpng-1.6.21/.libs/libpng16.16.bc
emcc: $(TARGET)
	mv $(TARGET) $(TARGET).js

all : $(TARGET)

$(TARGET): $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) $(INCLUDE) $(LDFLAGS) -o $@ $^

$(ODIR)/%.o: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(CC) $(CFLAGS) $(INCLUDE) -o $@ -c $<

debug: CFLAGS = $(CFLAGS) -O1 -g
debug: all

debugjs: $(EMCCFLAGS) = -O1 -g -s INLINING_LIMIT=10
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

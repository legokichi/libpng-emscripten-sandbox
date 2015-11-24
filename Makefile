PNGFLAGS := $(shell pkg-config libpng --cflags)
PNGLIBS := $(shell pkg-config libpng --libs)
CC = gcc -std=c11
CFLAGS = -O0 -Wall
INCLUDE = -I./include
ODIR = ./obj
SDIR = ./src
DIST = ./bin
SRCS = $(wildcard ./src/*.c)
OBJS = $(SRCS:./src/%.c=./obj/%.o)
TARGET = $(DIST)/a.out
EMCC = emcc -std=c11
EMFLAGS = -O3 -g3 --js-opts 1 --closure 2

all : $(TARGET)

$(TARGET): $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(CC) -o $@ $^ $(PNGLIBS)

$(ODIR)/%.o: $(SDIR)/%.c
	if [ ! -d $(ODIR) ]; then mkdir $(ODIR); fi
	$(CC) $(CFLAGS) $(PNGFLAGS) $(INCLUDE) -o $@ -c $<

debug: CFLAGS = -O1 -g
debug: all

run:
	./bin/a.out test.png

asmjs: ./src/*.c
	$(EMCC) $(EMFLAGS) $(PNGFLAGS) $(INCLUDE) $(DIST).js $(PNGLIBS) $^

debugjs: EMFLAGS = -O1 -g -s INLINING_LIMIT=10
debugjs: asmjs

runjs:
	cd ./bin
	node a.out.js ../test.png



.PHONY: clean
clean:
	rm -rf $(ODIR) $(DIST)

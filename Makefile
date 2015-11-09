PNGFLAGS := $(shell pkg-config libpng --cflags)
PNGLIBS := $(shell pkg-config libpng --libs)
INCLUDE = -I./include
EMCC = ~/emsdk_portable/emscripten/master/emcc
CC = gcc
CFLAGS =  -std=c11 -O3
EMFLAGS = -std=c11 -O3 -g3 --js-opts 1 --closure 2
DIST = ./bin/a.out

default:
	make build
	make run

build: ./src/*.c
	$(CC) $(CFLAGS) $(PNGFLAGS) $(INCLUDE) -o $(DIST) $(PNGLIBS) $^

debug: CFLAGS = -O1 -g
debug: build

run:
	./bin/a.out test.png

debugjs: EMFLAGS = -O1 -g -s INLINING_LIMIT=10
debugjs: asmjs

asmjs: ./src/*.c
	$(EMCC) $(EMFLAGS) $(PNGFLAGS) $(INCLUDE) -o $(DIST).js $(PNGLIBS) $^

runjs:
	cd ./bin
	node a.out.js ../test.png

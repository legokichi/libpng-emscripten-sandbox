PNGFLAGS := $(shell pkg-config libpng --cflags)
PNGLIBS := $(shell pkg-config libpng --libs)
INCLUDE = -I./include
EMCC = ~/emsdk_portable/emscripten/master/emcc -std=c11
CC = gcc -std=c11
DIST = ./bin/a.out

default:
	make build
	make run

build: ./src/*.c
	$(CC) -O3 $(PNGFLAGS) $(INCLUDE) -o $(DIST) $(PNGLIBS) $^

asmjs: ./src/*.c
	$(EMCC) -O3 -g3 --js-opts 1 --closure 2 $(PNGFLAGS) $(INCLUDE) -o $(DIST).js $(PNGLIBS) $^

run:
	./bin/a.out test.png

runjs:
	cd ./bin
	node a.out.js ../test.png

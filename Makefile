PNGFLAGS := $(shell pkg-config libpng --cflags)
PNGLIBS := $(shell pkg-config libpng --libs)

uselibpng: uselibpng.c
	gcc -O2 $(PNGFLAGS) uselibpng.c  $(PNGLIBS)

test:
	./a.out test.png 

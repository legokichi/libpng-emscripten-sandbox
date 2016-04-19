INCLUDE := -I./include $(shell pkg-config libpng --cflags) $(shell pkg-config libpng --libs)
CFLAGS := -Wall -O0
CC := gcc -std=c11
LD := gcc
LDFLAGS =
ODIR := ./obj
SDIR := ./src
DIST := ./bin
SRCS := $(wildcard ./src/*.c)
OBJS := $(SRCS:./src/%.c=./obj/%.o)
TARGET := $(DIST)/a
SUFFIX := .out

all: $(TARGET)

wasm: CFLAGS := -Wall -Demscripten=true -Dstandalone=true
wasm: LDFLAGS += -s BINARYEN=1 -s "BINARYEN_METHOD='interpret-binary'"# -s "BINARYEN_SCRIPTS='spidermonkify.py'"
wasm: LDFLAGS += -s EXPORTED_FUNCTIONS="['png_sig_cmp', 'png_create_read_struct', 'png_create_info_struct', 'png_destroy_read_struct', 'png_jmpbuf', 'png_init_io', 'png_set_sig_bytes', 'png_read_info', 'png_get_IHDR', 'png_get_rowbytes', 'png_read_image', 'png_read_end', 'png_destroy_read_struct']"
wasm: SUFFIX := .wasm
### fuck make
wasm: CC := emcc -std=c11
#wasm: CFLAGS += -O1 --llvm-opts 0
wasm: INCLUDE := -I./include -I./zlib-1.2.8 -I./libpng-1.6.21
wasm: LD := emcc
#wasm: LDFLAGS += -O1 --llvm-lto 0
wasm: LDFLAGS += -s EXCEPTION_DEBUG=1 -s ASSERTIONS=1
#wasm: LDFLAGS += -shared --memory-init-file 0 -s ALLOW_MEMORY_GROWTH=1 -O3 -g3 --js-opts 1 --closure 2
wasm: LDFLAGS += ./zlib-1.2.8/libz.bc ./libpng-1.6.21/.libs/libpng16.16.bc
wasm: $(TARGET)

asmjs: CFLAGS := -Wall -Demscripten=true
asmjs: LDFLAGS += -s EXPORTED_FUNCTIONS="['_open_png_file']"
asmjs: LDFLAGS += --pre-js ./src/em-pre.js --post-js ./src/em-post.js
asmjs: SUFFIX := .js
### fuck make
asmjs: CC := emcc -std=c11
#asmjs: CFLAGS += -O1 --llvm-opts 0
asmjs: INCLUDE := -I./include -I./zlib-1.2.8 -I./libpng-1.6.21
asmjs: LD := emcc
#asmjs: LDFLAGS += -O1 --llvm-lto 0
asmjs: LDFLAGS += -s EXCEPTION_DEBUG=1 -s ASSERTIONS=1
#asmjs: LDFLAGS += -shared --memory-init-file 0 -s ALLOW_MEMORY_GROWTH=1 -O3 -g3 --js-opts 1 --closure 2
asmjs: LDFLAGS += ./zlib-1.2.8/libz.bc ./libpng-1.6.21/.libs/libpng16.16.bc
asmjs: $(TARGET)

$(TARGET): $(OBJS)
	if [ ! -d $(DIST) ]; then mkdir $(DIST); fi
	$(LD) -o $@$(SUFFIX) $(INCLUDE) $(LDFLAGS) $^

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

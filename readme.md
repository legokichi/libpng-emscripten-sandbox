# libpng-emscripten-sandbox


## download libraries

```sh
wget http://zlib.net/zlib-1.2.8.tar.gz
wget http://download.sourceforge.net/libpng/libpng-1.6.21.tar.gz
tar zxvf zlib-1.2.8.tar.gz
tar zxvf libpng-1.6.21.tar.gz
rm zlib-1.2.8.tar.gz libpng-1.6.21.tar.gz
```
## complie libraries

```sh
alias gcc=clang
cd zlib-1.2.8
./configure
make
../
cd libpng-1.6.21
sed -e "s/\#define PNG_ZLIB_VERNUM 0x1250/\#define PNG_ZLIB_VERNUM 0x1280/g" pnglibconf.h > pnglibconf.h.tmp
mv pnglibconf.h pnglibconf.h.org
mv pnglibconf.h.tmp pnglibconf.h
./configure --with-zlib-prefix='../zlib-1.2.8'
make
```

## compile and link

```sh
emcc -std=c11 -Wall -O1 -I./zlib-1.2.8 -I./libpng-1.6.21 -c zlib-1.2.8/gzlib.c libpng-1.6.21/png.c src/main.c
emcc -o a.out.js --pre-js ./src/em-pre.js --post-js ./src/em-post.js    main.o gzlib.o png.o
```

### WTGF

```
$ emcc -o a.out.js --pre-js ./src/em-pre.js --post-js ./src/em-post.js    main.o gzlib.o png.o
warning: unresolved symbol: png_read_info
warning: unresolved symbol: png_destroy_read_struct
warning: unresolved symbol: png_get_IHDR
warning: unresolved symbol: png_malloc_base
warning: unresolved symbol: png_set_longjmp_fn
warning: unresolved symbol: png_read_end
warning: unresolved symbol: png_create_read_struct
warning: unresolved symbol: png_error
warning: unresolved symbol: png_read_image
warning: unresolved symbol: png_get_rowbytes
```

## reference
* http://dencha.ojaru.jp/programs_07/pg_graphic_10a2.html
* http://invar6.blog.fc2.com/category3-1.html
* http://invar6.blog.fc2.com/blog-entry-9.html
* http://diary.jdigital.be/toshi/mingw_gui/013.html
* http://gmoon.jp/png/

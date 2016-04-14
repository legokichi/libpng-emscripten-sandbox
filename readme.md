# libpng-emscripten-sandbox


## download libraries

```sh
wget http://zlib.net/zlib-1.2.8.tar.gz
wget http://download.sourceforge.net/libpng/libpng-1.6.21.tar.gz
tar zxvf zlib-1.2.8.tar.gz
tar zxvf libpng-1.6.21.tar.gz
rm zlib-1.2.8.tar.gz libpng-1.6.21.tar.gz
```

### libpngの準備

```sh
cd libpng-1.6.21
```

zlib の `zlib.h` の `ZLIB_VERNUM` と
libpng の `pnglibconf.h` の `PNG_ZLIB_VERNUM` が一致していなければ無理やり一致させる(API変わっていたらダメなので一致するバージョンを用意しましょう)

また、configure の `--with-zlib-prefix` オプションが emconfigure を使うと何故か効かなくなるので `ZPREFIX` へ直接 zlib へのパスを書き込みます。

```sh
sed -i -e "s/\#define PNG_ZLIB_VERNUM 0x1250/#define PNG_ZLIB_VERNUM 0x1280/g" ./pnglibconf.h
sed -i -e "s/ZPREFIX\=\'z\_\'/ZPREFIX='..\/zlib-1.2.8\/'/g" ./configure
emconfigure ./configure --with-zlib-prefix='../zlib-1.2.8/'
sed -i -e "s/^DEFAULT_INCLUDES \= \-I\./DEFAULT_INCLUDES = -I. -I..\/zlib-1.2.8\//g" ./Makefile
sed -i -e "s/^LIBS \= \-lz/LIBS = -L..\/zlib-1.2.8\//g" ./Makefile
```

```sh
emmake make --include-dir=../zlib-1.2.8/
```

`make` では共有ライブラリしか作れないので改めてスタティックライブラリを作る。

```sh
emcc -static  -fno-common -DPIC  .libs/png.o .libs/pngerror.o .libs/pngget.o .libs/pngmem.o .libs/pngpread.o .libs/pngread.o .libs/pngrio.o .libs/pngrtran.o .libs/pngrutil.o .libs/pngset.o .libs/pngtrans.o .libs/pngwio.o .libs/pngwrite.o .libs/pngwtran.o .libs/pngwutil.o   -L../zlib-1.2.8/ -lc    -Wl,-soname -Wl,libpng16.16.dylib -Wl,-retain-symbols-file -Wl,libpng.sym -o .libs/libpng16.16.bc
```

これで `.libs/libpng16.16.bc` ができた。

### コンパイル&リンク

コンパイルは普通にヘッダファイルのディレクトリを `-I` で参照させる。
リンク時に `./zlib-1.2.8/libz.bc` と `./libpng-1.6.21/.libs/libpng16.16.bc` を含めること。

```sh
emcc -std=c11 -Wall -I./zlib-1.2.8 -I./libpng-1.6.21 -o ./obj/main.bc -c ./src/main.c
emcc -O1 -o ./bin/a.out.js --pre-js ./src/em-pre.js --post-js ./src/em-post.js ./zlib-1.2.8/libz.bc ./libpng-1.6.21/.libs/libpng16.16.bc ./obj/main.bc
```

## reference
* http://dencha.ojaru.jp/programs_07/pg_graphic_10a2.html
* http://invar6.blog.fc2.com/category3-1.html
* http://invar6.blog.fc2.com/blog-entry-9.html
* http://diary.jdigital.be/toshi/mingw_gui/013.html
* http://gmoon.jp/png/
* https://kripken.github.io/emscripten-site/docs/compiling/Building-Projects.html
* http://d.hatena.ne.jp/sleepy_yoshi/20090510/p1
* http://www.ysr.net.it-chiba.ac.jp/data/cc.html

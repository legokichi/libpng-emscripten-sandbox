# libpng-emscripten-sandbox


## download libraries
```
wget http://zlib.net/zlib-1.2.8.tar.gz
wget http://download.sourceforge.net/libpng/libpng-1.6.21.tar.gz
tar zxvf zlib-1.2.8.tar.gz
tar zxvf libpng-1.6.21.tar.gz
rm zlib-1.2.8.tar.gz libpng-1.6.21.tar.gz
```
## complie libraries

```
cd zlib-1.2.8
./configure
make
../
cd libpng-1.6.21
./configure --with-zlib-prefix='../zlib-1.2.8'
make
```

## using libpng


## reference
* http://dencha.ojaru.jp/programs_07/pg_graphic_10a2.html
* http://invar6.blog.fc2.com/category3-1.html
* http://invar6.blog.fc2.com/blog-entry-9.html
* http://diary.jdigital.be/toshi/mingw_gui/013.html
* http://gmoon.jp/png/

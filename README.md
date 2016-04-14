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

#include <png.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

void open_png_file(const char* file_name_ptr);

#if !defined(emscripten)
int main(int argc, char** argv){
  printf("[%s", *argv);
  for(int32_t i=1; i<argc; i++){
    printf(", %s", *(argv+i));
  }
  printf("]\n");

  int8_t* file_name_ptr;
  if (argc < 2){
    fprintf(stderr, "Usage: program_name <file_in>\n");
    abort();
    //file_name_ptr = &"/home/web_user/orthogonal.png";
  }else{
    file_name_ptr = (int8_t*)*(argv+1); // typeof argv[1] == char *
  }
  printf("file_name_ptr:%d\n", (int)file_name_ptr);
  open_png_file((const char*)file_name_ptr);

  return 0;
}
#endif

#if !defined(standalone)
void open_png_file(const char* file_name_ptr){
  printf("fopen: %s\n", file_name_ptr);

  FILE* fp = fopen(file_name_ptr, "rb");
  printf("fp: %d\n", (int)fp);
  if (!fp){
    fprintf(stderr, "[read_png_file] File %s could not be opened for reading\n", file_name_ptr);
    abort();
  }
  fseek(fp, 0, SEEK_SET);

  int8_t header[8]; // 8 is the maximum size that can be checked
  fread((void *)header, 1, 8, fp);
  if (png_sig_cmp((void *)header, 0, 8)){
    fprintf(stderr, "[read_png_file] File %s is not recognized as a PNG file\n", file_name_ptr);
    abort();
  }
  printf("maybe png file");

  // initialize structure
  // Next, png_struct and png_info need to be allocated and initialized.
  // png_ptr構造体を確保 初期化
  png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if(!png_ptr){
    fprintf(stderr, "[read_png_file] png_create_read_struct failed\n");
    abort();
  }
  // info_ptr 構造体を確保 初期化
  png_infop info_ptr = png_create_info_struct(png_ptr);
  if(!info_ptr){
    png_destroy_read_struct(&png_ptr, NULL, NULL);
    fprintf(stderr, "[read_png_file] png_create_info_struct failed\n");
    abort();
  }
  png_infop end_info = png_create_info_struct(png_ptr);
  if(!end_info){
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fprintf(stderr, "[read_png_file] png_create_info_struct failed\n");
    abort();
  }

  // file registration
  // read file error handling
  if (setjmp(png_jmpbuf(png_ptr))){
    fprintf(stderr, "[read_png_file] Error during init_io\n");
    fclose(fp);
    abort();
  }
  // libpng に fp を知らせる
  png_init_io(png_ptr, fp);
  // 事前にシグネチャを読込確認済なら、ファイル先頭から読み飛ばしているバイト数を知らせる
  png_set_sig_bytes(png_ptr, 8);

  // read info
  uint32_t width, height;
  int32_t bit_depth, color_type, filter, compression, interlace;
  png_read_info(png_ptr, info_ptr);
  png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type, &interlace, &compression, &filter);

  printf("width: %d\n",       width);
  printf("height: %d\n",      height);
  printf("color_type: %d\n",  color_type);
  printf("bit_depth: %d\n",   bit_depth);
  printf("filter: %d\n",      filter);
  printf("compression: %d\n", compression);
  printf("interlace: %d\n",   interlace);

  // read png file
  if (setjmp(png_jmpbuf(png_ptr))){
    fprintf(stderr, "[read_png_file] Error during read_image\n");
    abort();
  }
  uint8_t ** row_pointers = (png_bytepp)malloc(height * sizeof(png_bytep)); // 以下３行は２次元配列を確保します
  //row_pointers = png_malloc(png_ptr, height*sizeof(png_bytep));

  for (int y=0; y<height; y++){
    row_pointers[y] = (png_bytep)malloc(png_get_rowbytes(png_ptr, info_ptr));
  }

  png_read_image(png_ptr, row_pointers);
  png_read_end(png_ptr, NULL);

  for (int32_t y=0; y<height; y++){
    for (int32_t x = 0; x<width; x++){
      //printf("%d ", (int)row_pointers[y][x*4+0]);
      //printf("%d ", (int)row_pointers[y][x*4+1]);
      //printf("%d ", (int)row_pointers[y][x*4+2]);
      //printf(row_pointers[y][x*4+0] < 127 ? " " : "|");
      printf(row_pointers[y][x*4+1] < 127 ? " " : "|");
      //printf(row_pointers[y][x*4+2] < 127 ? " " : "|");
      printf(row_pointers[y][x*4+3] < 127 ? " " : "|");
    }
    printf("\n");
  }

  // free
  // 以下２行は２次元配列を解放します
  for (int32_t i = 0; i < height; i++){
    free(row_pointers[i]);
  }
  free(row_pointers);
  png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
  fseek(fp, 0, SEEK_SET);
  fclose(fp);
}
#endif

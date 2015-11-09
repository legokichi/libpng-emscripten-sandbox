#include <zlib.h>
#include <png.h>
#include <stdio.h>
#include <stdlib.h>
#include <main.h>

int main(int argc, char **argv){
  printf("[%s", *argv);
  for(int i=1; i<argc; i++){
    printf(", %s", *(argv+i));
  }
  printf("]\n");

  if (argc < 2){
    fprintf(stderr, "Usage: program_name <file_in>\n");
    abort();
  }
  // http://dencha.ojaru.jp/programs_07/pg_graphic_10a2.html
  // http://invar6.blog.fc2.com/category3-1.html
  // http://invar6.blog.fc2.com/blog-entry-9.html
  char* file_name = *(argv+1);
  FILE *fp = fopen(file_name, "rb");

  // check signature
  if(fseek(fp, 0, SEEK_SET) != 0){
    fprintf(stderr, "seek failed: %s", file_name);
    abort();
  }
  if (!fp){
    fprintf(stderr, "[read_png_file] File %s could not be opened for reading", file_name);
    abort();
  }
  char header[8]; // 8 is the maximum size that can be checked
  fread((void *)header, 1, 8, fp);
  if (png_sig_cmp((void *)header, 0, 8)){
    fprintf(stderr, "[read_png_file] File %s is not recognized as a PNG file", file_name);
    abort();
  }

  // initialize structure
  png_structp png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
  if(!png_ptr){
    fprintf(stderr, "[read_png_file] png_create_read_struct failed");
    abort();
  }
  png_infop info_ptr = png_create_info_struct(png_ptr);
  if(!info_ptr){
    png_destroy_read_struct(&png_ptr, NULL, NULL);
    fprintf(stderr, "[read_png_file] png_create_info_struct failed");
    abort();
  }
  // end
  png_infop end_info = png_create_info_struct(png_ptr);
  if(!end_info){
    png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
    fprintf(stderr, "end");
    abort();
  }
  // error
  // setjmp: http://www.ne.jp/asahi/hishidama/home/tech/c/setjmp.html
  if(setjmp(png_jmpbuf(png_ptr))){
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
    fprintf(stderr, "error");
    abort();
  }

  // read file
  if (setjmp(png_jmpbuf(png_ptr))){
    fprintf(stderr, "[read_png_file] Error during init_io");
    abort();
  }

  // file registration
  png_init_io(png_ptr, fp);
  png_set_sig_bytes(png_ptr, 8);

  // read info
  unsigned int width, height;
  int bit_depth, color_type, filter, compression, interlace;
  png_read_info(png_ptr, info_ptr);
  png_get_IHDR(png_ptr, info_ptr, &width, &height, &bit_depth, &color_type, &interlace, &compression, &filter);

  // read file
  if (setjmp(png_jmpbuf(png_ptr))){
    fprintf(stderr, "[read_png_file] Error during read_image");
    abort();
  }
  /*
  png_bytep row_pointers[height] = (png_bytep*) malloc(sizeof(png_bytep) * height);
  for (int y=0; y<height; y++){
    row_pointers[y] = (png_byte*) malloc(png_get_rowbytes(png_ptr,info_ptr));
  }
  png_read_image(png_ptr, row_pointers);
  png_read_end(png_ptr, NULL);
  */


  // free
  png_destroy_read_struct(&png_ptr, &info_ptr, &end_info);
  fseek(fp, 0, SEEK_SET);
  fclose(fp);

  printf("width: %d\n", width);
  printf("height: %d\n", height);
  printf("color_type: %d\n", color_type);
  printf("bit_depth: %d\n", bit_depth);
  printf("filter: %d\n", filter);
  printf("compression: %d\n", compression);
  printf("interlace: %d\n", interlace);

  return 0;
}

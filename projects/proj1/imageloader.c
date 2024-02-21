/************************************************************************
**
** NAME:        imageloader.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**              Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-15
**
**************************************************************************/

#include "imageloader.h"
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Opens a .ppm P3 image file, and constructs an Image object.
// You may find the function fscanf useful.
// Make sure that you close the file with fclose before returning.
Image *readData(char *filename) {
  FILE *const fp = fopen(filename, "r");

  uint32_t column, row, range;
  fscanf(fp, "P3 %" SCNd32 " %" SCNd32 " %" SCNd32, &column, &row, &range);

  Color **dat = malloc(sizeof(Color *) * row);
  for (uint32_t r = 0; r < row; r++) {
    Color *v = malloc(sizeof(Color) * column);
    for (uint32_t c = 0; c < column; c++) {
      fscanf(fp, "%" SCNd8 " %" SCNd8 " %" SCNd8, &v[c].R, &v[c].G, &v[c].B);
    }
    dat[r] = v;
  }

  fclose(fp);

  Image *ret = malloc(sizeof(Image));
  ret->cols = column;
  ret->rows = row;
  ret->image = dat;
  return ret;
}

static void writeColor(const struct Color p) {
  printf("%3" PRId8 " %3" PRId8 " %3" PRId8, p.R, p.G, p.B);
}

// Given an image, prints to stdout (e.g. with printf) a .ppm P3 file with the
// image's data.
void writeData(const Image *image) {
  printf("P3\n");
  printf("%" PRId32 " %" PRId32 "\n", image->cols, image->rows);
  printf("255\n");
  for (uint32_t r = 0; r < image->rows; ++r) {
    writeColor(image->image[r][0]);
    for (uint32_t c = 1; c < image->cols; ++c) {
      printf("   ");
      writeColor(image->image[r][c]);
    }
    printf("\n");
  }
}

// Frees an image
void freeImage(Image *image) {
  for (uint32_t r = 0; r < image->rows; r++) {
    free(image->image[r]);
  }
  free(image->image);
  free(image);
}

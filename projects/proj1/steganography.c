/************************************************************************
**
** NAME:        steganography.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Dan Garcia  -  University of California at Berkeley
**              Copyright (C) Dan Garcia, 2020. All rights reserved.
**				Justin Yokota - Starter Code
**				YOUR NAME HERE
**
** DATE:        2020-08-23
**
**************************************************************************/

#include "imageloader.h"
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// Determines what color the cell at the given row/col should be. This should
// not affect Image, and should allocate space for a new Color.
Color *evaluateOnePixel(Image *image, int row, int col) {
  static const struct Color white = {.R = 0xff, .G = 0xff, .B = 0xff},
                            black = {.R = 0, .G = 0, .B = 0};
  Color *r = malloc(sizeof(Color));
  *r = image->image[row][col].B & 0x01 ? white : black;
  return r;
}

// Given an image, creates a new image extracting the LSB of the B channel.
Image *steganography(Image *image) {
  Color **dat = malloc(sizeof(Color *) * image->rows);
  for (uint32_t r = 0; r < image->rows; r++) {
    Color *d = malloc(sizeof(Color) * image->cols);
    for (uint32_t c = 0; c < image->cols; c++) {
      Color *v = evaluateOnePixel(image, r, c);
      d[c] = *v;
      free(v);
    }
    dat[r] = d;
  }

  Image *ret = malloc(sizeof(Image));
  *ret = (struct Image){.image = dat, .cols = image->cols, .rows = image->rows};

  return ret;
}

/*
Loads a file of ppm P3 format from a file, and prints to stdout (e.g. with
printf) a new image, where each pixel is black if the LSB of the B channel is 0,
and white if the LSB of the B channel is 1.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a file of ppm P3 format (not
necessarily with .ppm file extension). If the input is not correct, a malloc
fails, or any other error occurs, you should exit with code -1. Otherwise, you
should return from main with code 0. Make sure to free all memory before
returning!
*/
int main(int argc, char **argv) {
  if (argc < 2) {
    return -1;
  }
  Image *input = readData(argv[1]);
  Image *output = steganography(input);
  writeData(output);

  freeImage(input);
  freeImage(output);
  return 0;
}

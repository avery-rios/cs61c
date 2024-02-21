/************************************************************************
**
** NAME:        gameoflife.c
**
** DESCRIPTION: CS61C Fall 2020 Project 1
**
** AUTHOR:      Justin Yokota - Starter Code
**				YOUR NAME HERE
**
**
** DATE:        2020-08-23
**
**************************************************************************/

#include "imageloader.h"
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static uint32_t colorToInt(Color c) { return (c.R << 16) | (c.G << 8) | c.B; }

// Determines what color the cell at the given row/col should be. This function
// allocates space for a new Color. Note that you will need to read the eight
// neighbors of the cell in question. The grid "wraps", so we treat the top row
// as adjacent to the bottom row and the left column as adjacent to the right
// column.
Color *evaluateOneCell(Image *image, int row, int col, uint32_t rule) {
  const int left_column = col == 0 ? image->cols - 1 : col - 1;
  const int right_column = col == image->cols - 1 ? 0 : col + 1;
  const int top_row = row == 0 ? image->rows - 1 : row - 1;
  const int bottom_row = row == image->rows - 1 ? 0 : row + 1;

  Color **dat = image->image;
  const uint32_t cent = colorToInt(dat[row][col]);
  const uint32_t mat[8] = {colorToInt(dat[top_row][left_column]),
                           colorToInt(dat[top_row][col]),
                           colorToInt(dat[top_row][right_column]),
                           colorToInt(dat[row][left_column]),
                           colorToInt(dat[row][right_column]),
                           colorToInt(dat[bottom_row][left_column]),
                           colorToInt(dat[bottom_row][col]),
                           colorToInt(dat[bottom_row][right_column])};

  uint32_t val = 0;
  for (int i = 0; i < 24; ++i) {
    int live_neighbor = 0;
    for (int j = 0; j < 8; j++) {
      live_neighbor += (mat[j] >> i) & 1;
    }
    const int offset = live_neighbor + (((cent >> i) & 1) ? 9 : 0);
    val |= ((rule >> offset) & 1) << i;
  }

  Color *ret = malloc(sizeof(Color));
  *ret =
      (struct Color){.R = val >> 16, .G = (val >> 8) & 0xff, .B = val & 0xff};
  return ret;
}

// The main body of Life; given an image and a rule, computes one iteration of
// the Game of Life. You should be able to copy most of this from
// steganography.c
Image *life(Image *image, uint32_t rule) {
  Color **dat = malloc(sizeof(Color *) * image->rows);
  for (uint32_t r = 0; r < image->rows; r++) {
    Color *v = malloc(sizeof(Color) * image->cols);
    for (uint32_t c = 0; c < image->cols; c++) {
      Color *d = evaluateOneCell(image, r, c, rule);
      v[c] = *d;
      free(d);
    }
    dat[r] = v;
  }

  Image *ret = malloc(sizeof(Image));
  ret->image = dat;
  ret->rows = image->rows;
  ret->cols = image->cols;

  return ret;
}

/*
Loads a .ppm from a file, computes the next iteration of the game of life, then
prints to stdout the new image.

argc stores the number of arguments.
argv stores a list of arguments. Here is the expected input:
argv[0] will store the name of the program (this happens automatically).
argv[1] should contain a filename, containing a .ppm.
argv[2] should contain a hexadecimal number (such as 0x1808). Note that this
will be a string. You may find the function strtol useful for this conversion.
If the input is not correct, a malloc fails, or any other error occurs, you
should exit with code -1. Otherwise, you should return from main with code 0.
Make sure to free all memory before returning!

You may find it useful to copy the code from steganography.c, to start.
*/
int main(int argc, char **argv) {
  if (argc < 3) {
    return -1;
  }

  Image *input = readData(argv[1]);
  const uint32_t rule = strtol(argv[2], NULL, 16);

  Image *output = life(input, rule);
  writeData(output);

  freeImage(input);
  freeImage(output);

  return 0;
}

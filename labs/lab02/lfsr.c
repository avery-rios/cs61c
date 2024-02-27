#include "lfsr.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void lfsr_calculate(uint16_t *reg) {
  const uint16_t rv = *reg;
  uint16_t b = rv;
  b ^= rv >> 2;
  b ^= rv >> 3;
  b ^= rv >> 5;
  *reg = (rv >> 1) | ((b & 1) << 15);
}

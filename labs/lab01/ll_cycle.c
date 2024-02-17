#include "ll_cycle.h"
#include <stddef.h>

int ll_has_cycle(node *head) {
  node *tort = head, *hare = head;
  while (hare) {
    hare = hare->next;
    if (!hare) {
      return 0;
    }
    hare = hare->next;
    tort = tort->next;
    if (hare == tort) {
      return 1;
    }
  }
  return 0;
}

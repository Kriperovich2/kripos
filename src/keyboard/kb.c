#include "kb.h"

unsigned char get_queue(void) {
    if (head == tail){return 0;}
    unsigned char ch = queue[tail];
    tail = (tail + 1) % size;
    return ch;
}


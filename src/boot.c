#include "io.h"

extern logo, prompt;

void main()
{
    disable_cursor();
    clear_screen();
    printlnk(logo);
    printlnk("");
    //strcpy(input_buffer, prompt);
    cmd();
}

void cmd()
{
   printk(prompt);
}

#include "io.h"

extern logo, prompt;

char clear_screen_str[2000] = {[0 ... 1999] = ' '};

void main()
{
    disable_cursor();
    clear_screen();
    printlnk(logo);
    printlnk("");
    cmd();
}

void cmd()
{
   int line_o = 0;
   char last;
   char dout = 0;

   printk(prompt);
   while (1)
   {
    keyboard_interrupt();
    unsigned char ch;

    while ((ch = get_queue()) != 0)
    {
        if (ch && ch != last ) {
            printk_line(clear_screen_str, 8);
            clear_screen_str[line_o] = ch;
            line_o++;
            last = ch;
            }
        
        if (line_o == 2000) {
            line_o = 0;
        }
    }}
}

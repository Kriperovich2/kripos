// Клавиатура из Linux 0.11, переписано под C
// (Не подпадает под линуксовую лицензию :)
// (Наверное ......)

#define size 1024


unsigned char key_mode = 0;	// Капс, альт, контрл и шифт
unsigned char leds = 2;	// Нам-лок, капс, скрол
unsigned char e0 = 0;

unsigned char queue[size];
int head = 0;
int tail = 0;

unsigned char key_map[] = {
    0,   27, 
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=',
    127, 9,
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',
    '\n',  0,
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'',
    '`', 0,
    '\\','z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',
    0,   '*', 0,   ' ',
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,
    '-', 0,   0,   0,   '+',
    0,   0,   0,   0,   0,   0,   0,
    '<',
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};

unsigned char shift_map[] = {
    0,   27, 
    '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+',
    127, 9,
    'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}',
    '\n',  0,
    'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '"',
    '~', 0,
    '|', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '<', '>', '?',
    0,   '*', 0,   ' ',
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,
    '-', 0,   0,   0,   '+',
    0,   0,   0,   0,   0,   0,   0,
    '>',
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};

unsigned char alt_map[] = {
    0,   0,
    0,   '@', 0,   '$', 0,   0,   '{', '[', ']', '}', '\\', 0,
    0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    '~', '\n',  0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   ' ',
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,	
    0,   0,   0,   0,   0,
    0,   0,   0,   0,   0,   0,   0,
    '|',
    0,   0,   0,   0,   0,   0,   0,   0,   0,   0
};

unsigned char num_table[] = "789 456 1230,";
unsigned char cur_table[] = "HA5 DGC YB623";

unsigned int func_table[] = {
    0x415b5b1b, 0x425b5b1b, 0x435b5b1b, 0x445b5b1b,
    0x455b5b1b, 0x465b5b1b, 0x475b5b1b, 0x485b5b1b,
    0x495b5b1b, 0x4a5b5b1b, 0x4b5b5b1b, 0x4c5b5b1b
};

// Как это бл-ть работает?
void keyboard_interrupt(void)
{
    unsigned char scancode;
    
    scancode = inb(0x60);
    
    if (scancode == 0xe0) {
        e0 = 1;
        goto get_handler;
    }
    if (scancode == 0xe1) {
        e0 = 2;
        goto get_handler;
    }
    
    // Обработчик клавиш равен нужному
    switch (scancode) {
        // Ну вот и, бл-ть, работает (зажатие)
        case 0x1d: ctrl(1); break;
        case 0x2a: lshift(1); break;
        case 0x36: rshift(1); break;
        case 0x38: alt(1); break;
        case 0x3a: caps(1); break;
        case 0x46: scroll(1); break;
        case 0x45: num(1); break;
        
        // отпуск
        case 0x9d: unctrl(1); break;
        case 0xaa: unlshift(1); break;
        case 0xb6: unrshift(1); break;
        case 0xb8: unalt(1); break;
        case 0xba: uncaps(1); break;
        
        // специальные клавиши
        case 0x37: minus(1); break;  // Кейпад
        
        // БОЖЕ БОЖЕ, ЧТО ЭТА?
        case 0x47: case 0x48: case 0x49: case 0x4a: case 0x4b: case 0x4c: case 0x4d: case 0x4e: case 0x4f: case 0x50: case 0x51: case 0x52: case 0x53: cursor(scancode); break; // Клавиши курсора
        case 0x3b: case 0x3c: case 0x3d: case 0x3e: case 0x3f: case 0x40: case 0x41: case 0x42: case 0x43: case 0x44: func(scancode); break;  // F1-F10
        case 0x57: case 0x58: func(scancode); break;  // F11-F12
        
        default: do_self(scancode); break;
    }
    
    e0 = 0;
    
get_handler:
    // Получение прерывания клавиш (БЛ_ТЬ, Я НИ__Я НЕ ПОНИМАЮ)
    scancode = inb(0x61);
    outb(scancode | 0x80, 0x61);
    outb(scancode & 0x7F, 0x61);
    outb(0x20, 0x20);
}

// Вставить клавишу
void put_queue(unsigned int ch)
{
    do {
        queue[head] = ch & 0xff;
        head = (head + 1) % size;
        if (head == tail){return;}
        ch >>= 8;
    } while (ch);
}

// Ожидание контроллера клавиатуры
void kb_wait(void)
{
    unsigned char status;
    do {
        status = inb(0x64);
    } while (status & 0x02);
}

// Подсветка (я это переписал как есть, но я хз как работает)
void set_leds(void)
{
    kb_wait();
    outb(0xed, 0x60);
    kb_wait();
    outb(leds, 0x60);
}

// "Нормальные" клавиши
void do_self(unsigned char scancode)
{
    unsigned char ch;
    unsigned char *keymap;

    if (key_mode & 0x20){keymap = alt_map;}
    else if (key_mode & 0x03){keymap = shift_map;}
    else {keymap = key_map;}

    ch = keymap[scancode];
    if (!ch){return;}

    // Капс и контролл
    if ((key_mode & 0x4c) && (ch >= 'a' && ch <= '}')){ch -= 32;}
    if ((key_mode & 0x0c) && (ch >= 64 && ch < 64+32)){ch -= 64;}

    // Альт
    if (key_mode & 0x10){ch |= 0x80;}

    put_queue(ch);
}

// Кнопки курсора
void cursor(unsigned char scancode)
{
    unsigned char ch;
    
    scancode -= 0x47;
    if (scancode > 12){return;}
        
    // ctrl-alt-del
    if (scancode == 0 && (key_mode & 0x0c) && (key_mode & 0x30)){reboot();}
        
    // Намлок или шифт
    if (e0 != 1 && !(leds & 0x02) && !(key_mode & 0x03)) {
        ch = num_table[scancode];
        if (ch != ' '){put_queue(ch);}
        return;
    }
    
    ch = cur_table[scancode];
    if (ch > '9'){put_queue(ch);}
    else {
        put_queue(0x1b);
        put_queue('[');
        put_queue(ch);
    }
}

// Функциональные клавиши
void func(unsigned char scancode)
{
    unsigned int code;
    
    if (scancode < 0x3b || (scancode > 0x44 && scancode < 0x57) || scancode > 0x58){return;}
    if (scancode <= 0x44){scancode -= 0x3b;}
    else {scancode -= 0x57;}
    
    if (scancode > 11){return;}
        
    code = func_table[scancode];
    put_queue(code & 0xff);
    put_queue((code >> 8) & 0xff);
    put_queue((code >> 16) & 0xff);
}

// Опять-же, что бл-ть (модификаторы)
void ctrl(int press) 
{
    key_mode |= (e0 ? 0x08 : 0x04);
}

void unctrl(int press) 
{
    key_mode &= ~(e0 ? 0x08 : 0x04);
}

void lshift(int press) 
{
    key_mode |= 0x01;
}

void unlshift(int press) 
{
    key_mode &= ~0x01;
}

void rshift(int press) 
{
    key_mode |= 0x02;
}

void unrshift(int press) 
{
    key_mode &= ~0x02;
}

void alt(int press) 
{
    key_mode |= (e0 ? 0x20 : 0x10);
}

void unalt(int press) 
{
    key_mode &= ~(e0 ? 0x20 : 0x10);
}

void caps(int press) 
{
    if (!(key_mode & 0x80)) {
        leds ^= 0x04;
        key_mode ^= 0x40;
        key_mode |= 0x80;
        set_leds();
    }
}

void uncaps(int press) 
{
    key_mode &= ~0x80;
}

void scroll(int press) 
{
    leds ^= 0x01;
    set_leds();
}

void num(int press) 
{
    leds ^= 0x02;
    set_leds();
}

void minus(int press) 
{
    if (e0 == 1){put_queue('/');}
    else {do_self(0x4a);}  // '-'
}

void reboot(void)
{
    kb_wait();
    // *((unsigned short *)0x472) = 0x1234;
    // outb(0xfc, 0x64);
    while (1);
    // У меня это не работает
}
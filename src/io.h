char line = 0;
char input_buffer[256] = {0};

char key_map[] = {
    0, 27,
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=',
    127, 9,
    'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']',
    '\n', 0,
    'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'',
    '`', 0,
    '\\', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/',
    0, '*', 0, 32,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    '-', 0, 0, 0, '+',
    0, 0, 0, 0, 0, 0, 0,
    '<',
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

void printk(char* message) // Вывод в текстовом режиме
{
	char *vidmem = (char*)0xb8000; // Видео-память в текстовом режиме находится тут
	unsigned int i=0;

	i=(line*80*2);

	while(*message!=0)
	{                       // Каждый символ видео-памяти
                            // занимает 2 байта, а именно символ и цвет
		if(*message=='\n')
		{
			line++;
			i=(line*80*2);
			*message++;
		} else {
			vidmem[i]=*message;
			*message++;
			i++;
			vidmem[i]=0x07;
			i++;
		};
	};
}

void printlnk(char* message) // Вывод в текстовом режиме + переход на новую строку
{
	printk(message);
	line++;
}

void clear_screen() {     // Заполнить пробелами
    char *vidmem = (char*)0xb8000;
    unsigned int i;
    for (i = 0; i < 80 * 25; i++) {
        vidmem[i * 2] = ' ';
        vidmem[i * 2 + 1] = 0x07;
    }
    line = 0;
}

char getchar() // получить символ
{ 	char key = 0;
	while (key == 0){
		key = key_map[inb(0x60)]; // 0x60 - порт клавиатуры
	}
	return key;
}

// void sleep()
// {
// 	for (int i = 0; i < 19440000; i++) {
// 		34534445534534 % i;
// 	}
// }

char *strcpy(char *dest, const char *src)
{
    char *tmp = dest;
    while ((*dest++ = *src++) != '\0');
    return tmp;
}

// char *strncpy(char *dest, const char *src, int count)
// {
//     char *tmp = dest;
//     while (count-- && (*dest++ = *src++) != '\0');
//     while (count-- > 0)
//         *dest++ = '\0';
//     return tmp;
// }

void __stack_chk_fail_local(){}
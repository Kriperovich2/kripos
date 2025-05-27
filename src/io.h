char line = 0;
char input_buffer[256] = {0};

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

void printk_line(char* message, char line) // Вывод в текстовом режиме с нужной линией
{
	char *vidmem = (char*)0xb8000;
	unsigned int i=0;

	i=(line*80*2);

	while(*message!=0)
	{
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

void putchark(char ch, char column, char line)
{
    char *vidmem = (char*)0xb8000;
    vidmem[(line*80*2)+column*2] = ch;
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

void __stack_chk_fail_local(){}
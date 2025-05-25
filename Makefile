all: build qemu

build: asm c link

asm:
	nasm -f elf32 src/boot.asm -o sign.o
	nasm -f elf32 src/entry.asm -o entry.o
	nasm -f elf32 src/io.asm -o io.o

c:
	gcc -m32 -c src/boot.c -o cboot.o
	gcc -m32 -c src/logo.c -o logo.o

link:
	ld -m elf_i386 -T linker.ld -o kernel entry.o sign.o cboot.o logo.o io.o

clean-temp:
	rm -f *.o

clean: clean-temp
	rm -f kernel

qemu:
	qemu-system-i386 -kernel kernel
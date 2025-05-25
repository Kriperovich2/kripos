bits 32 ; Multiboot - x32!

; Тут только MultiBoot-header от Grub, ниже стоит его сигнатура. (Точка входа в другом файле)

section .text
	align 4
	dd 0x1BADB002
	dd 0x00
	dd - (0x1BADB002 + 0x00)
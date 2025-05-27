bits 32

global disable_cursor, inb, inb_p, outb, outb_p

disable_cursor: ; вручную отключить VGA курсор
	pushf
	push eax
	push edx

	mov dx, 0x3D4
	mov al, 0xA
	out dx, al

	inc dx
	mov al, 0x20
	out dx, al

	pop edx
	pop eax
	popf
	ret

inb: ; in - чтение порта
    push ebp
    mov ebp, esp
    mov ax, [ebp + 8]
    mov dx, ax
    in al, dx
    mov [ebp - 4], al
    movzx eax, byte [ebp - 4]
    leave
    ret

inb_p:
    push ebp
    mov ebp, esp
    sub esp, 4
    mov edx, [ebp + 8]
    in al, dx
    mov [ebp - 4], al
    movzx eax, byte [ebp - 4]
    leave
    ret

outb: ; out - запись порта
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov edx, [ebp + 12]
    out dx, al
    leave
    ret

outb_p:
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]
    mov edx, [ebp + 12]
    out dx, al
    leave
    ret
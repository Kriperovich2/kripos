org 0x7C00
bits 16

start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti
    
    ; Очистка экрана
    mov ax, 0x0003
    int 0x10
    
    ; Приветствие
    mov si, welcome_msg
    call print_str

main_loop:
    mov si, prompt
    call print_str
    
    call read_input
    
    mov si, input_buf
    
    mov di, cmd_help
    call str_cmp
    jc .do_help
    
    mov di, cmd_shut
    call str_cmp
    jc .do_shut
    
    mov di, cmd_reboot
    call str_cmp
    jc .do_reboot
    
    mov di, cmd_clear
    call str_cmp
    jc .do_clear
    
    mov di, cmd_info
    call str_cmp
    jc .do_info
    
    mov di, cmd_ver
    call str_cmp
    jc .do_ver
    
    mov si, unknown_cmd
    call print_str
    jmp main_loop

.do_help:
    mov si, help_msg
    call print_str
    jmp main_loop

.do_shut:
    mov si, shut_msg
    call print_str
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    hlt
    jmp main_loop

.do_reboot:
    mov si, reboot_msg
    call print_str
    call delay
    int 0x19
    mov ax, 0
    mov ds, ax
    mov [0], ax
    jmp 0xFFFF:0
    jmp main_loop

.do_clear:
    mov ax, 0x0003
    int 0x10
    jmp main_loop

.do_info:
    mov si, info_msg
    call print_str
    jmp main_loop

.do_ver:
    mov si, ver_msg
    call print_str
    jmp main_loop

.do_pong:
    mov si, pong_msg
    call print_str
    jmp main_loop

; ----- Основные функции -----

read_input:
    mov di, input_buf
    mov cx, 32
    xor al, al
    rep stosb
    mov di, input_buf
.key:
    mov ah, 0
    int 0x16
    
    cmp al, 0x0D
    je .done
    
    cmp al, 0x08
    je .back
    
    cmp di, input_buf+31
    ja .key
    
    stosb
    mov ah, 0x0E
    int 0x10
    jmp .key
.back:
    cmp di, input_buf
    jbe .key
    
    dec di
    mov byte [di], 0
    
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .key
.done:
    mov byte [di], 0
    mov si, newline
    call print_str
    ret

delay:
    push cx
    mov cx, 0xFFFF
.delay_loop:
    nop
    loop .delay_loop
    pop cx
    ret

str_cmp:
    pusha
.loop:
    mov al, [si]
    mov bl, [di]
    cmp al, bl
    jne .no
    test al, al
    jz .yes
    inc si
    inc di
    jmp .loop
.yes:
    popa
    stc
    ret
.no:
    popa
    clc
    ret

print_str:
    lodsb
    test al, al
    jz .done
    mov ah, 0x0E
    int 0x10
    jmp print_str
.done:
    ret

; ----- Данные -----

welcome_msg db "KripOS Console v1.0", 0x0D, 0x0A, 0
prompt db "krip@fastuser:~$", 0
newline db 0x0D, 0x0A, 0
unknown_cmd db "unknown", 0x0D, 0x0A, 0

input_buf times 32 db 0

cmd_help db "help", 0
cmd_shut db "shut", 0
cmd_reboot db "reboot", 0
cmd_clear db "clear", 0
cmd_info db "info", 0
cmd_ver db "ver", 0
cmd_pong db "ping", 0

help_msg db "Cmds:", 0x0D, 0x0A
         db "help - list", 0x0D, 0x0A
         db "shut - off", 0x0D, 0x0A
         db "info - sys", 0x0D, 0x0A 
         db "clear - scr", 0x0D, 0x0A
         db "reboot", 0x0D, 0x0A
         db "ver - version", 0x0D, 0x0A
         db "ping - PONG!", 0x0D, 0x0A, 0

shut_msg db "Power off", 0x0D, 0x0A, 0
reboot_msg db "Rebooting", 0x0D, 0x0A, 0

info_msg db "KripOS v1", 0x0D, 0x0A
         db "Author-Kriperovich", 0x0D, 0x0A
         db "Idea-x16 PRos", 0x0D, 0x0A, 0

ver_msg  db "KripOS version 1.0", 0x0D, 0x0A
         db "Build: Stable", 0x0D, 0x0A
         db "Arch: x86 (16-bit)", 0x0D, 0x0A
         db "(c) 2025 Kriperovich", 0x0D, 0x0A, 0

; очень важная обнова :D
pong_msg db "PONG!" 0x0D, 0x0A

times 510-($-$$) db 0
dw 0xAA55

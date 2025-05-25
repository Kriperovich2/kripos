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

    ; Очистка экрана (меньше байт, чем mov ax, 0x0003 + int 0x10)
    mov ah, 0x00
    mov al, 0x03
    int 0x10

    ; Оптимизированный вывод логотипа (меньше строк)
    mov si, logo
    call print_str

    call command_help

main_loop:
    mov si, prompt
    call print_str
    
    call read_input
    call exec_command
    jmp main_loop

; ========== Функции ==========
read_input:
    mov di, input_buf
    mov cx, 10
    xor al, al
    rep stosb
    mov di, input_buf
.key:
    xor ah, ah       ; xor использует меньше байт чем mov ah, 0
    int 0x16
    
    cmp al, 0x0D
    je .done
    
    cmp al, 0x08
    je .back
    
    cmp di, input_buf+9
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
    
    mov ax, 0x0E08   ; Объединяем два mov в один
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

exec_command:
    mov si, command_table
.check:
    mov di, input_buf
    call str_cmp
    jc .found
    add si, 6
    cmp si, command_table_end
    jb .check
    mov si, unknown_cmd
    call print_str
    ret
.found:
    add si, 5
    call word [si]
    ret

str_cmp:
    pusha
.loop:
    lodsb
    cmp al, [di]
    jne .no
    test al, al
    jz .yes
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

; ========== Команды ==========
command_help:
    mov si, help_msg
    call print_str
    ret

command_shut:
    mov si, shut_msg
    call print_str
    ; Более компактный способ выключения
    mov ax, 0x2000
    mov dx, 0x604
    out dx, ax
    hlt
    ret

; ========== Данные ==========
; Объединенный логотип (меньше места)
logo db "  _  __  _ __     _  __", 0x0D, 0x0A
     db " | |/ /  _ \|_ _|  _ \   / _ \/ ___|", 0x0D, 0x0A
     db " | ' /| |_)   |_) | | | | \___ \", 0x0D, 0x0A
     db " | . \|  _ < | ||  __/  | |_| |___) |", 0x0D, 0x0A
     db " |_|\_\_| \_\___|_|      \___/|____/", 0x0D, 0x0A, 0

prompt db "KripOS> ", 0
newline db 0x0D, 0x0A, 0
unknown_cmd db "Unknown cmd", 0x0D, 0x0A, 0  ; Сокращено
help_msg db "Commands:", 0x0D, 0x0A         ; Сокращено
         db " help - This msg", 0x0D, 0x0A
         db " shut - Power off", 0x0D, 0x0A, 0
shut_msg db "Shutting down...", 0x0D, 0x0A, 0

input_buf times 8 db 0  ; Уменьшен буфер

; Таблица команд (оптимизированная)
command_table:
    db "help", 0
    dw command_help
    db "shut", 0
    dw command_shut
command_table_end:

; Загрузочная сигнатура
times 510-($-$$) db 0
dw 0xAA55

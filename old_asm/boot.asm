org 0x7C00
bits 16

; Объявляем внешние символы
extern command_help
extern command_shut
extern command_table
extern command_table_end

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

    ; Оптимизированный вывод логотипа
    mov si, logo1
    call print_str
    mov si, logo2
    call print_str
    mov si, logo3
    call print_str

    ; Автовывод справки
    call command_help

main_loop:
    mov si, prompt
    call print_str
    
    ; Чтение команды
    call read_input
    
    ; Обработка команды
    call exec_command
    jmp main_loop

; ----- Основные функции -----
read_input:
    mov di, input_buf
    mov cx, 8          ; Уменьшенный буфер
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
    
    cmp di, input_buf+7
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

exec_command:
    mov si, command_table
.check:
    mov di, input_buf
    call str_cmp
    jc .found
    add si, 5          ; Уменьшенный размер записи
    cmp si, command_table_end
    jb .check
    
    mov si, unknown_cmd
    call print_str
    ret
.found:
    call [si+4]        ; Оптимизированный вызов
    ret

str_cmp:
    pusha
.loop:
    mov al, [si]
    cmp al, [di]
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
logo1 db "  _  __  _ __", 0x0D, 0x0A, 0
logo2 db " | |/ / | | |", 0x0D, 0x0A, 0
logo3 db " |_|\_\_|_|_|", 0x0D, 0x0A, 0

prompt db "KripOS> ", 0
newline db 0x0D, 0x0A, 0
unknown_cmd db "Unknown cmd", 0x0D, 0x0A, 0
input_buf times 8 db 0

times 510-($-$$) db 0
dw 0xAA55

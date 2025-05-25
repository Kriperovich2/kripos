; commands.asm - реализация команд с объявлением зависимостей

; Объявляем внешние функции
extern print_str

; Команда help
command_help:
    mov si, help_msg
    call print_str
    ret

; Команда shut
command_shut:
    mov si, shut_msg
    call print_str
    mov dx, 0x604
    mov ax, 0x2000
    out dx, ax
    hlt
    ret

section .data
help_msg db "Available commands:", 0x0D, 0x0A
         db " help - Show help", 0x0D, 0x0A
         db " shut - Power off", 0x0D, 0x0A, 0
shut_msg db "Shutting down...", 0x0D, 0x0A, 0

command_table:
    db "help", 0
    dw command_help
    db "shut", 0
    dw command_shut
command_table_end:

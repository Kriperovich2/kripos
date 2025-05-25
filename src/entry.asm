bits 32

global start ; Точка входа должна быть всегда глобальной
extern main ; Это из кода C


start:
    cli ; Выключить прерывания
    
    call main

    hlt ; Ничего не делать
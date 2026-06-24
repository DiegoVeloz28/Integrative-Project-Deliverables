global long_mode_start
extern kernel_main

section .text
bits 64
long_mode_start:
    ; Limpiar registros de segmento de datos
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Llamar al Kernel en C
    call kernel_main
    hlt

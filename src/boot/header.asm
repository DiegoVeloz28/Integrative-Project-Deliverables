section .multiboot_header
header_start:
    dd 0xe85250d6                ; firma mágica de Multiboot2
    dd 0                         ; arquitectura (i386)
    dd header_end - header_start ; longitud del header
    ; Checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; Tag de fin
    dw 0
    dw 0
    dd 8
header_end:

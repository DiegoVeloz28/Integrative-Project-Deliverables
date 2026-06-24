global start
extern long_mode_start

section .text
bits 32
start:
    mov esp, stack_top

    ; Apuntar tablas de paginación (Identity mapping)
    mov eax, p3_table
    or eax, 0b11 ; present + writable
    mov [p4_table], eax

    mov eax, p2_table
    or eax, 0b11
    mov [p3_table], eax

    ; Mapear el primer Gigabyte (Huge pages de 2MB)
    mov ecx, 0
.map_p2_table:
    mov eax, 0x200000  ; 2MB
    mul ecx
    or eax, 0b10000011 ; present + writable + huge
    mov [p2_table + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .map_p2_table

    ; Habilitar paginación
    mov eax, p4_table
    mov cr3, eax
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
    mov eax, cr0
    or eax, 1 << 31
    mov cr0, eax

    ; Cargar GDT de 64 bits y saltar
    lgdt [gdt64.pointer]
    jmp gdt64.code:long_mode_start

section .bss
align 4096
p4_table: resb 4096
p3_table: resb 4096
p2_table: resb 4096
stack_bottom: resb 4096
stack_top:

section .rodata
gdt64:
    dq 0
.code: equ $ - gdt64
    dq (1<<43) | (1<<44) | (1<<47) | (1<<53)
.pointer:
    dw $ - gdt64 - 1
    dq gdt64

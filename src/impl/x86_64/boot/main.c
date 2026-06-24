#include <stdint.h>

void print_str(const char* str) {
    // Puntero a la memoria de video VGA
    uint16_t* video_memory = (uint16_t*) 0xb8000;
    
    // Limpiar pantalla primero (espacios en negro/blanco)
    for (int i = 0; i < 80 * 25; i++) {
        video_memory[i] = (uint16_t) ' ' | (15 << 8);
    }

    // Escribir el mensaje
    int index = 0;
    while (str[index] != '\0') {
        video_memory[index] = (uint16_t) str[index] | (15 << 8); // 15 = Letra blanca, fondo negro
        index++;
    }
}

void kernel_main() {
    print_str("Welcome to 64-bit kernel - Diego (DAVE), Flavio Granizo, Alex Gaibor");
    while(1) {} // Bucle infinito para que no se apague
}

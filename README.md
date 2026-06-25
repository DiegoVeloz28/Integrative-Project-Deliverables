Project: 64-bit Kernel Build (Part 2)
Group Members:

Diego Veloz (Compilation and Architecture Correction)

Flavio Granizo

Alex Gaibor

Subject: Operating Systems Security
University: Universidad Internacional del Ecuador (UIDE)

🛠️ 1. Reproducible Development Environment (Docker)
The project utilizes a fully isolated and reproducible build environment based on Docker, ensuring cross-platform compatibility (including emulated support for ARM64/Apple Silicon architectures via qemu-user-static).

Key tools integrated into the image:

NASM: Assembler for 32-bit and 64-bit boot components.

GCC Cross-Compiler: Cross-compiler configured to generate freestanding binaries in long mode.

GRUB & xorriso: Used to package the final binary within a bootable ISO structure (kernel.iso).

🚀 2. Build and Emulation Instructions
Automated Build (Single Command)
To launch the container, compile the Assembly/C source files, link the binary, and generate the final ISO image, run:

Bash
sudo make build
Emulation
To test the generated image using the QEMU emulator:

Bash
qemu-system-x86_64 -cdrom kernel.iso
.PHONY: build
build:
	docker build -t my-kernel-build .
	docker run --rm -v $(CURDIR):/root/env my-kernel-build make kernel.iso

kernel.iso:
	nasm -f elf64 src/boot/header.asm -o header.o
	nasm -f elf64 src/boot/main.asm -o main.o
	nasm -f elf64 src/boot/main64.asm -o main64.o
	gcc -c -m64 -ffreestanding src/impl/x86_64/boot/main.c -o main_c.o
	ld -n -o kernel.bin -T targets/x86_64/linker.ld header.o main.o main64.o main_c.o
	mkdir -p iso/boot/grub
	cp kernel.bin iso/boot/kernel.bin
	printf 'set timeout=0\nset default=0\nmenuentry "My Kernel" {\n multiboot2 /boot/kernel.bin\n boot\n}' > iso/boot/grub/grub.cfg
	grub-mkrescue -o kernel.iso iso
	rm -rf iso *.o kernel.bin

# Initializing variables
ASM = as
ASMFLAGS = --32 -g
LDFLAGS = -m elf_i386 -T linker.ld -nostdlib -g

# Main part
all: boot.o kernel.o int32.o
	ld boot.o kernel.o int32.o -o MyOS.bin $(LDFLAGS)

boot.o: boot.s
	$(ASM) $(ASMFLAGS) boot.s -o boot.o

kernel.o: kernel.s # kernel.c
	gcc -m32 -c kernel.c -o kernel.o -std=c90 -ffreestanding -O0 -Wall -Wextra
	#$(ASM) $(ASMFLAGS) kernel.s -o kernel.o

int32.o: int32.asm
	nasm -f elf int32.asm	

clean:
	rm -f *.o MyOS.out MyOS.bin MyOS.iso
	rm -rf boot/

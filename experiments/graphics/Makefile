# Initializing variables
ASM = as
ASMFLAGS = --32 -g
LDFLAGS = -m elf_i386 -T linker.ld -nostdlib -g

# Main part
all: boot.o kernel.o
	ld boot.o kernel.o -o MyOS.bin $(LDFLAGS)

boot.o: boot.s
	$(ASM) $(ASMFLAGS) boot.s -o boot.o

kernel.o: kernel.c
	gcc -m32 -c kernel.c -o kernel.o -std=c90 -ffreestanding -O2 -Wall -Wextra
	#$(ASM) $(ASMFLAGS) kernel.s -o kernel.o	

clean:
	rm -f *.o MyOS.out MyOS.bin MyOS.iso
	rm -rf boot/

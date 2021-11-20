# Initializing variables
ASM = as
ASMFLAGS = --32
LINK = ld
LDFLAGS = -melf_i386 --oformat=binary -e _start -Ttext 0x7c00

main: boot.bin

boot.bin: boot.o
	$(LINK) $(LDFLAGS) -o boot.bin boot.o

boot.o: boot.s
	$(ASM) $(ASMFLAGS) -o boot.o boot.s

dump: boot.bin
	hexdump boot.bin

qemu: boot.bin
	qemu-system-x86_64 boot.bin

burn: boot.bin
	./burn.sh

clean:
	rm -f *.o *.bin

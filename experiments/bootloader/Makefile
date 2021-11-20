# Initializing variables
ASM = as
ASMFLAGS = --32
LINK = ld
LDFLAGS = -melf_i386 --oformat=binary -Ttext 0x7c00 -nostartfiles -nostdlib

main: boot.bin

boot.bin: boot.o
	$(LINK) $(LDFLAGS) boot.o -o boot.bin

boot.o: boot.s
	$(ASM) $(ASMFLAGS) boot.s -o boot.o

burn: boot.bin
	./burn.sh

clean:
	rm -f *.o

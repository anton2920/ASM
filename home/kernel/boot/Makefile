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

objdump: boot.bin
	objdump -D boot.bin

run: boot.bin
	killall qemu-kvm || exit 0
	/usr/libexec/qemu-kvm boot.bin &
	sleep 0.1
	vncviewer localhost:5900
	killall qemu-kvm || exit 0

burn: boot.bin
	./burn.sh

clean:
	rm -f *.o *.bin

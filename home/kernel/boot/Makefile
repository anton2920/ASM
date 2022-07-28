FNAME = boot
TXTSTART = 0x7c00

ASM = as
ASMFLAGS = --32
LINK = ld
LDFLAGS = -melf_i386 --oformat=binary -e _start -Ttext $(TXTSTART)

main: $(FNAME).bin

$(FNAME).bin: $(FNAME).o
	$(LINK) $(LDFLAGS) -o $(FNAME).bin $(FNAME).o

$(FNAME).o: $(FNAME).s ioroutines.s x86prot.s boot32.s
	$(ASM) $(ASMFLAGS) -o $(FNAME).o $(FNAME).s

dump: $(FNAME).bin
	hexdump $(FNAME).bin

objdump: $(FNAME).bin
	objdump -b binary --adjust-vma=$(TXTSTART) -D -m i386 $(FNAME).bin

run: $(FNAME).bin
	killall qemu-kvm || exit 0
	/usr/libexec/qemu-kvm $(FNAME).bin &
	sleep 0.1
	vncviewer localhost:5900
	killall qemu-kvm || exit 0

burn: $(FNAME).bin
	./burn.sh

clean:
	rm -f *.o *.bin

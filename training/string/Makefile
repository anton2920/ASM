# Initializing vatiables
asm = as
ASFLAGS = --32
link = ld
LDFLAGS = -m elf_i386 -dynamic-linker /lib32/ld-linux.so.2 -lc
LDFLAGS_64 = -dynamic-linker /lib/ld-linux_x86-64.so.2 -lc
DEBUG = -g

# Main part
all: main.o routines.o
	$(link) main.o routines.o -o strings $(DEBUG) $(LDFLAGS)

main.o: main.s
	$(asm) main.s -o main.o $(DEBUG) $(ASFLAGS)

routines.o: routines.s
	$(asm) routines.s -o routines.o $(DEBUG) $(ASFLAGS)

clean:
	rm -f *.o wavp
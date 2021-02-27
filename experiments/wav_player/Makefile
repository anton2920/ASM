# Initializing vatiables
asm = as
ASFLAGS = --32
link = ld
LDFLAGS = -m elf_i386 -dynamic-linker /lib32/ld-linux.so.2 -lc -lasound
DEBUG = -g

# Main part
all: main.o routines.o print_info.o
	$(link) main.o routines.o print_info.o -o wavp $(DEBUG) -m elf_i386 $(LDFLAGS)

main.o: main.s
	$(asm) main.s -o main.o $(DEBUG) $(ASFLAGS)

routines.o: routines.s
	$(asm) routines.s -o routines.o $(DEBUG) $(ASFLAGS)

print_info.o: print_info.s
	$(asm) print_info.s -o print_info.o $(DEBUG) $(ASFLAGS)

clean:
	rm -f *.o wavp
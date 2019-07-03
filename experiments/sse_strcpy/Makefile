# Initializing variables
asm = as
link = ld
ASMFLAGS = --32
LDFLAGS = -lc -dynamic-linker /lib32/ld-linux.so.2 -m elf_i386
DEBUG = -g

# Main part
all: main.o
	$(link) main.o -o main $(DEBUG) $(LDFLAGS)

main.o: main.s
	$(asm) main.s -o main.o $(DEBUG) $(ASMFLAGS)

clean:
	rm -f *.o main
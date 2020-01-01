# Initializing variables
ASM = as
ASMFLAGS = --32 -g
LDFLAGS = -lc -dynamic-linker /lib32/ld-linux.so.2 -m elf_i386 -g

# Main part
all: main.o
	ld main.o -o main $(LDFLAGS)

main.o: main.s
	$(ASM) $(ASMFLAGS) main.s -o main.o

clean:
	rm -f *.o main
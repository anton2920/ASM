# Initializing variables
ASM = as
ASMFLAGS = -g --32
LINKER = ld
LDFLAGS = -m elf_i386 -g

# Main part
all: test.o
	$(LINKER) test.o -o test $(LDFLAGS)

test.o: test.s
	$(ASM) $(ASMFLAGS) test.s -o test.o

clean:
	rm -f *.o test

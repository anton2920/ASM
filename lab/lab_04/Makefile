# Initializing variables
ASM = as
LINKER = ld
ASM_ARGS = --32
MODE = -m elf_i386
DYN_DEP = -lc -dynamic-linker /lib32/ld-linux.so.2

all: a1.o
	$(LINKER) a1.o -o a1 $(DYN_DEP) $(MODE)

a1.o: a1.s
	$(ASM) a1.s -o a1.o $(ASM_ARGS)

clean:
	rm -f *.o a1
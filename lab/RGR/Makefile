# Initializing variables
ASM = as
LINKER = ld
ARGS = -g
ASM_ARGS = --32
MODE = -m elf_i386
DYN_DEP = -lc -dynamic-linker /lib32/ld-linux.so.2

all: rgr

rgr: main.o menu.o routines.o
	$(LINKER) $(ARGS) main.o menu.o routines.o -o rgr $(DYN_DEP) $(MODE)

main.o: main.s
	$(ASM) $(ARGS) main.s -o main.o $(ASM_ARGS)

menu.o: menu.s
	$(ASM) $(ARGS) menu.s -o menu.o $(ASM_ARGS)

routines.o: routines.s
	$(ASM) $(ARGS) routines.s -o routines.o $(ASM_ARGS)

clean:
	rm -f *.o rgr
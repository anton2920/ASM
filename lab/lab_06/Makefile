# Initializing variables
ASM = as
ARGS = -g

all: calc

calc: calc.o math.o routines.o
	ld calc.o math.o routines.o -o calc -m elf_i386 $(ARGS)

calc.o: calc.s
	$(ASM) calc.s -o calc.o --32 $(ARGS)

math.o: math.s
	$(ASM) math.s -o math.o --32 $(ARGS)

routines.o: routines.s
	$(ASM) routines.s -o routines.o --32 $(ARGS)

clean:
	rm -f *.o calc

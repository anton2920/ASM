# Initializing variables
ASM = as
ARGS = -g

all: main

main: a1.o tasks.o routines.o
	ld a1.o tasks.o routines.o -o a1 -m elf_i386 $(ARGS)

a1.o: a1.s
	$(ASM) a1.s -o a1.o --32 $(ARGS)

tasks.o:	tasks.s
	$(ASM) tasks.s -o tasks.o --32 $(ARGS)

routines.o:
	$(ASM) routines.s -o routines.o --32 $(ARGS)

clean:
	rm -f *.o a1

# Initializing variables
ASM = as
LINKER = ld
ASMFLAGS = --32
LDFLAGS = -m elf_i386 # -lc -dynamic-linker /lib32/ld-linux.so.2
DEBUG = -g

all: main.o routines.o
	$(LINKER) main.o routines.o -o main $(LDFLAGS) $(DEBUG)

main.o: main.s
	$(ASM) main.s -o main.o $(ASMFLAGS) $(DEBUG)

routines.o: routines.s
	$(ASM) routines.s -o routines.o $(ASMFLAGS) $(DEBUG)

clean:
	rm -f *.o main
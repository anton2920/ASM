# Initializing variables
LINKER = ld
LDFLAGS = -m elf_i386
DEBUG = -g

PROG_NAME = find_outlier

# Main part
all:

nasm: find_nasm link

gas: find_gas link

link:
	$(LINKER) $(DEBUG) $(PROG_NAME).o -o $(PROG_NAME) $(LDFLAGS)

NASM = nasm
NASMFLAGS = -f elf32
find_nasm: $(PROG_NAME).nasm
	$(NASM) $(NASMFLAGS) $(DEBUG) $(PROG_NAME).nasm -o $(PROG_NAME).o

GAS = as
GASFLAGS = --32
find_gas: $(PROG_NAME).s
	$(GAS) $(GASFLAGS) $(DEBUG) $(PROG_NAME).s -o $(PROG_NAME).o

clean:
	rm -f *.o $(PROG_NAME)

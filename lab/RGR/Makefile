# Initializing variables
ASM = as
LINKER = ld
DEBUG = -g
ASFLAGS = --32
MODE = -m elf_i386
# LDFLAGS = -dynamic-linker /usr/lib/ld-linux.so.2 -lc
LDFLAGS = -dynamic-linker /lib32/ld-linux.so.2 -lc

all: rgr

rgr: main.o menu.o routines.o db.o
	$(LINKER) $(DEBUG) main.o menu.o routines.o db.o -o rgr $(LDFLAGS) $(MODE)

main.o: main.s
	$(ASM) $(DEBUG) main.s -o main.o $(ASFLAGS)

menu.o: menu.s
	$(ASM) $(DEBUG) menu.s -o menu.o $(ASFLAGS)

routines.o: routines.s
	$(ASM) $(DEBUG) routines.s -o routines.o $(ASFLAGS)
db.o: db.s
	$(ASM) $(DEBUG) db.s -o db.o $(ASFLAGS)

clean:
	rm -f *.o rgr
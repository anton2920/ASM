# Initializing variables
ASM = as
LINKER = ld
ASFLAGS = --32 -g
LIBSTDC = -lc -dynamic-linker /lib/ld-linux.so.2
LDFLAGS = -m elf_i386 -g $(LIBSTDC)

# Main part
all: server client routines
	$(LINKER) server.o routines.o -o server $(LDFLAGS)
	$(LINKER) client.o routines.o -o client $(LDFLAGS)

server: server.s
	$(ASM) server.s -o server.o $(ASFLAGS)

client: client.s
	$(ASM) client.s -o client.o $(ASFLAGS)

routines: routines.s
	$(ASM) routines.s -o routines.o $(ASFLAGS)

clean:
	rm -f *.o server client
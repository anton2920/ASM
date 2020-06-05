# Initializing variables
ASM = as
CC = gcc
LINKER = ld
ASFLAGS = --32 -g
CFLAGS = -std=c90 -Wall -Wextra -O2
LIBSTDC = -lc -dynamic-linker /lib/ld-linux.so.2
LDFLAGS = -m elf_i386 -g $(LIBSTDC)
CLDFLAGS = -lpthread

# Main part
all: server client routines
	$(LINKER) server.o routines.o -o server $(LDFLAGS)

server: server.s
	$(ASM) server.s -o server.o $(ASFLAGS)

client: client.c
	$(CC) client.c -o client $(CLDFLAGS)

routines: routines.s
	$(ASM) routines.s -o routines.o $(ASFLAGS)

clean:
	rm -f *.o server client
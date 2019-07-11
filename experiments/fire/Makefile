# Initializing variables
asm = as
ASFLAGS = --32
link = ld
LDFLAGS = -m elf_i386 -dynamic-linker /lib32/ld-linux.so.2 -lSDL2 -lSDL2_image -lc
LDFLAGS_64 = -dynamic-linker /lib64/ld-linux_x86-64.so.2 -lSDL2 -lSDL2_image -lc
DEBUG = -g

# Main part
all: main.o sdl.o
	# $(link) main.o sdl.o -o main $(DEBUG) $(LDFLAGS)
	gcc main.o sdl.o -o main -lSDL2 -lSDL2_image $(DEBUG) -m32

x86-64: main_64.o sdl_64.o
	# $(link) main_64.o sdl_64.o -o main64 $(DEBUG) $(LDFLAGS_64)
	gcc main_64.o sdl_64.o -o main64 -lSDL2 -lSDL2_image -lGL $(DEBUG)

main.o: main.s
	$(asm) main.s -o main.o $(ASFLAGS) $(DEBUG)

sdl.o: sdl.s
	$(asm) sdl.s -o sdl.o $(ASFLAGS) $(DEBUG)

main_64.o: main_64.s
	$(asm) main_64.s -o main_64.o -gstabs

sdl_64.o: sdl_64.s
	$(asm) sdl_64.s -o sdl_64.o -gstabs

clean:
	rm -f *.o main

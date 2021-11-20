.code16

.section .text
.globl _start
_start:
	# Writing characters
	movb $0xE, %ah # Teletype write to active page
	leaw hello_str, %si # String buffer for 'lods'
	cld

_start_print_loop:
	lodsb
	testb %al, %al
	jz _start_print_loop_end

	int $0x10

	jmp _start_print_loop

_start_print_loop_end:
	hlt

# .section .rodata
hello_str:
	.asciz "Hello, world!\n"

# Zero padding
.org 510

# Magic number at the end, so BIOS will
# recognize this 512 as bootsector
.word 0xAA55

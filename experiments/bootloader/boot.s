.code16

.section .text
.globl _start
_start:
	# Setting screen mode (16/8-color, 80x25 EGA: 64-color)
	movb $0x00, %ah
	movb $0x13, %al
	int $0x10

	# Writing characters
	movb $0x9, %ah # Write attribute and charater at cursor position
	movw $hello_str, %dx # Our loop counter
	movb $0x1, %bh # Using page #1
	movb $0x1, %bl # Using initial color of Blue
	movw $0x1, %cx # Printing every character only once

_start_print_loop:
	movb (%edx), %al
	testb %al, %al
	jz _start_print_loop_end

	int $0x10

	incb %bl # Next colour
	incw %dx # Next character
	jmp _start_print_loop

_start_print_loop_end:
	int 0 # halt

# .section .rodata
hello_str:
	.asciz "Hello, world!"
	.equ hello_str_len, . - hello_str

# Zero padding
.org 510

# Magic number at the end, so BIOS will
# recognize this 512 as bootsector
.word 0xAA55

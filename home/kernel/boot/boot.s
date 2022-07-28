.code16

.section .text
.globl _start
_start:
	# Initialising stack frame
	movw %sp, %bp

	# Main part
	pushw $hello_str
	callw prints
	addw $0x2, %sp

	pushw $0x1234
	callw printw
	addw $0x2, %sp

	pushw $newline_str
	callw prints
	addw $0x2, %sp

	pushw $0xA
	callw printw
	addw $0x2, %sp

	pushw $newline_str
	callw prints
	addw $0x2, %sp

	# Exitting
	hlt

.include "ioroutines.s"

# .section .rodata
hello_str:
	.asciz "Hello, world!\r\n"

newline_str:
	.asciz "\r\n"

# Zero padding
.org 510

# Magic number at the end, so BIOS will
# recognize this 512 as bootsector
.word 0xAA55

.code16

.section .text
.globl _start
_start:
	leaw hello_str, %di
	callw prints

	movw $0x1234, %di
	callw printw

	leaw newline_str, %di
	callw prints

	movw $0xA, %di
	callw printw

	leaw newline_str, %di
	callw prints

	# Exitting
	jmp .

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

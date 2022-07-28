.code16

.section .text
.globl _start
_start:
	movw $0x8000, %sp
	movw %sp, %bp

	leaw booting_str, %di
	callw prints

	call switch_to_protected_mode # _Noreturn

# .section .rodata
booting_str:
	.asciz "Booting... "

.include "ioroutines.s" # prints
.include "x86prot.s" # switch_to_protected_mode

# Zero padding
.org 510

# Magic number at the end, so BIOS will
# recognize these 512 bytes as bootsector
.word 0xAA55

.code16

.section .text
.globl _start
_start:
	movw $0x8000, %sp
	movw %sp, %bp

	movb %dl, bootdrv

	leaw booting_str, %di
	callw prints

	.equ nsectors_read, 3
	movb $0x2, %ah # Command: read sectors into memory
	xorw %dx, %dx # Head number = 0
	movb bootdrv, %dl # Store bootdrive number back
	xorw %cx, %cx # Cylinder/Track number = 0
	movb $0x2, %cl # Sector number = 2
	movb $nsectors_read, %al # nsectors to read = 3
	movw $0x9000, %bx # Buffer address = ES:0x9000
	int $0x13

	jc _start_drive_error

	cmpb $nsectors_read, %al
	jne _start_drive_error_mismatch

	movw (%bx), %di
	callw printwln

	movw 512(%bx), %di
	callw printwln

	movw 1024(%bx), %di
	callw printwln

	jmp _start_end

_start_drive_error:
	movb $0x0, %ah
	pushw %ax

	leaw disk_error_str, %di
	callw prints

	popw %di
	callw printwln

	jmp _start_end

_start_drive_error_mismatch:
	movb $0x0, %ah
	pushw %ax

	leaw disk_error_mismatch_str, %di
	callw prints

	popw %di
	callw printwln

_start_end:
	jmp .

.include "ioroutines.s"

# .section .data
bootdrv:
	.byte 0

# .section .rodata
booting_str:
	.asciz "Booting...\r\n"

disk_error_str:
	.asciz "Disk error: "

disk_error_mismatch_str:
	.asciz "Disk read error: didn't read all sectors, got "

# Zero padding
.org 510

# Magic number at the end, so BIOS will
# recognize these 512 bytes as bootsector
.word 0xAA55

# Sector 2
.word 0xDADA
.zero 510

# Sector 3
.word 0xDEAD
.zero 510

# Sector 4
.word 0xBEEF
.zero 510

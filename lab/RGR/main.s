.section .data

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# Initializing variables

	# I/O flow
	call menu

	cmpl $0x0, %eax
	je exit

	cmpl $0x1, %eax
	je create_new

	jmp open_exist

create_new:
	call create_database

open_exist:
	#call open_database

exit:
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.section .data
format_output:
	.ascii "%d\n\0"

.section .text
.globl _start
_start:
	
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x8, %esp # Acquiring space for two variables

	# Initializing variables
	.equ x, -4
	.equ p, -8
	movl $0xA, x(%ebp) # x = 10
	leal x(%ebp), %eax
	movl %eax, p(%ebp) # p = &x

	# I/O flow
	movl p(%ebp), %eax
	pushl (%eax)
	pushl $format_output
	call printf
	addl $0x8, %esp

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.section .data
format_input:
	.ascii "%d\0"
format_output:
	.ascii "Type N: \0"
format_answer:
	.ascii "Answer: %d\n\0"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x4, %esp # Acquiring space in -4(%ebp)

	# I/O flow
	pushl $format_output
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part
	# 1 week = 7 days = 7 * 24 hours = 7 * 24 * 60 minutes = 7 * 24 * 60 * 60 seconds
	# First — convert seconds to hours (div 3600)
	# Second — find remainder from division by 24
	movl -4(%ebp), %eax # N
	xorl %edx, %edx
	movl $3600, %ebx
	idiv %ebx
	xorl %edx, %edx
	movl $24, %ebx
	idiv %ebx

	# Final output
	pushl %edx
	pushl $format_answer
	call printf
	addl $0x8, %esp

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

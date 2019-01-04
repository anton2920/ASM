.section .data
format_input:
	.ascii "%d\0"
format_output:
	.ascii "Type Yuiry's spendings on candies: \0"
format_answer:
	.ascii "Yuiry's annual income: %d\n\0"

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
	movl -4(%ebp), %eax
	imul $208, %eax

	# Final output
	pushl %eax
	pushl $format_answer
	call printf
	addl $0x8, %esp

	# Exiting
	movl $0x1, %eax
	xorl %ebp, %ebp
	int $0x80

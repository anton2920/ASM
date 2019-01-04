.section .data
format_input:
	.ascii "%d\0"
format_output:
	.ascii "Type a: \0"
format_answer:
	.ascii "a ^ 13 = %d\n\0"

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
	movl -4(%ebp), %eax # a
	movl %eax, %ebx # b = a
	imul %eax, %ebx # b = a ^ 2
	imul %eax, %ebx # b = a * a ^ 2 = a ^ 3
	imul %ebx, %ebx # b = b ^ 2 = a ^ 3 * a ^ 3 = a ^ 6
	imul %ebx, %ebx # b = b ^ 2 = a ^ 6 * a ^ 6 = a ^ 12
	imul %eax, %ebx # b = a * a ^ 12 = a ^ 13

	# Final output
	pushl %ebx
	pushl $format_answer
	call printf

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

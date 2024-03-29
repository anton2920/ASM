.section .data
format_input:
	.ascii "%d\0"
format_output:
	.ascii "Type a: \0"
format_answer:
	.ascii "a ^ 3 = %d, a ^ 10 = %d\n\0"

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
	imul %ebx, %ebx # b = a ^ 2
	movl %ebx, %ecx # c = b = a ^ 2
	imul %eax, %ebx # b = a * a ^ 2 = a ^ 3
	movl %ebx, %eax # a = b = a ^ 3
	imul %ecx, %ebx # b = c * b = a ^ 2 * a ^ 3 = a ^ 5
	imul %ebx, %ebx # b = a ^ 5 * a ^ 5 = a ^ 10
	movl %ebx, %ecx # c = b = a ^ 10

	# Final output
	pushl %ecx
	pushl %eax
	pushl $format_answer
	call printf
	add $0xC, %esp

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

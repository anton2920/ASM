.section .data
format_input:
	.ascii "%d\0"
format_output:
	.ascii "Type a number: \0"
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
	movl -4(%ebp), %eax # Number
	movl $0xA, %esi

	xorl %edx, %edx # %edx = 0
	idiv %esi
	pushl %edx

	xorl %edx, %edx # %edx = 0
	idiv %esi
	pushl %edx

	xorl %edx, %edx # %edx = 0
	idiv %esi
	pushl %edx

	xorl %edx, %edx # %edx = 0
	idiv %esi
	pushl %edx

	pushl %eax # Final digit

	# 12345, %eax = 1, %ebx = 2, %ecx = 3, %edx = 4, %edi = 5; %eax = 1, %ebx = 5, %ecx = 3, %edx = 4, %edi = 2;
	popl %eax
	popl %edi
	popl %ecx
	popl %edx
	popl %ebx

	imul $0xA, %eax
	addl %ebx, %eax
	imul $0xA, %eax
	addl %ecx, %eax
	imul $0xA, %eax
	addl %edx, %eax
	imul $0xA, %eax
	addl %edi, %eax

	# Final output
	pushl %eax
	pushl $format_answer
	call printf
	addl $0x8, %esi

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

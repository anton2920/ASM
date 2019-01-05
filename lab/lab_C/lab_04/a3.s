.section .data
format_input:
	.ascii "%d\0"
format_output1:
	.ascii "Type K [0; 365]: \0"
format_output2:
	.ascii "Type N [0; 6]: \0"
format_answer:
	.ascii "Answer: %d\n\0"
.equ K_VAR, -4
.equ N_VAR, -8

.section .text
.globl _start
_start:
	# Initialzing stack frame
	movl %esp, %ebp
	subl $0x8, %esp # Acquiring space in -4(%ebp) and in -8(%ebp)

	# I/O flow
	pushl $format_output1
	call printf
	addl $0x4, %esp

	leal K_VAR(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	pushl $format_output2
	call printf
	addl $0x4, %esp

	leal N_VAR(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part
	popl %ebx # N
	popl %eax # K
	addl %ebx, %eax
	movl $0x7, %ebx
	xorl %edx, %edx
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

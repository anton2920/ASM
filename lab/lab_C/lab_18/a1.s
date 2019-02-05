.section .data
format_output1:
	.ascii "Value of «a» equals to %d\n\0"
format_output2:
	.ascii "Address of «a» equals to %d\n\0"
format_output3:
	.ascii "Dereferenced value of «b» equals to %d\n\0"
format_output4:
	.ascii "Value of «b» equals to %d\n\0"
format_output5:
	.ascii "Address of «b» equals to %d\n\0"

.section .text
.globl _start
_start:

	# Initializing stack frame
	movl %esp, %ebp
	subl $0x8, %esp # Acquiring space for two variables

	# Initializing variables
	.equ a, -4
	.equ b, -8
	movl $134, a(%ebp) # a = 134
	leal a(%ebp), %eax
	movl %eax, b(%ebp) # b = &a

	# I/O flow
	pushl a(%ebp)
	pushl $format_output1
	call printf
	addl $0x8, %esp

	leal a(%ebp), %eax
	pushl %eax
	pushl $format_output2
	call printf
	addl $0x8, %esp

	movl b(%ebp), %eax
	pushl (%eax)
	pushl $format_output3
	call printf
	addl $0x8, %esp

	pushl b(%ebp)
	pushl $format_output4
	call printf
	addl $0x8, %esp

	leal b(%ebp), %eax
	pushl %eax
	pushl $format_output5
	call printf
	addl $0x8, %eax

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

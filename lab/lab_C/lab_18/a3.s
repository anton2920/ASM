.section .data
format_input:
	.ascii "%d\0"
format_output1:
	.ascii "Type a: \0"
format_output2:
	.ascii "Type b: \0"
format_answer:
	.ascii "Swapped: a = %d, b = %d\n\0"

.section .text
.globl _start
_start:
	
	# Initializing stack frame
	movl %esp, %ebp
	.equ var, -4
	subl $0x4, %esp # Acquiring space in -4(%ebp)

	# I/O flow
	pushl $format_output1
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax # a [-8(%ebp)]

	pushl $format_output2
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax # b [-12(%ebp)]

	# Main part
	leal -8(%ebp), %eax # a
	leal -12(%ebp), %ebx # b

	pushl %ebx
	pushl %eax
	call swap
	addl $0x8, %esp

	popl %ebx # b
	popl %eax # a
	pushl %ebx # b
	pushl %eax # a
	pushl $format_answer
	call printf
	addl $0xC, %esp

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type swap, @function
swap:
	
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	.equ a, 8
	.equ b, 12
	movl a(%ebp), %eax # a
	movl b(%ebp), %ebx # b

	# Main part
	movl (%eax), %ecx # c = *a
	movl (%ebx), %edx # d = *b
	movl %ecx, (%ebx) # *b = a
	movl %edx, (%eax) # *a = b

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

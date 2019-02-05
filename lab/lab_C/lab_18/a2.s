.section .data
a_mas:
	.long 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21
format_output:
	.ascii "a[0] = %d, a[1 + N] = %d, a[1 + 2 * N % 21] = %d\n\0"

.section .text
.globl _start
.equ N, 15
_start:
	
	# Initializing stack frame
	movl %esp, %ebp
	.equ var, -4
	subl $0x4, %esp # Aqcuiring space in -4(%ebp)

	# Initializing variables
	movl $a_mas, %eax
	movl %eax, var(%ebp)

	# I/O flow
	movl $N, %eax
	imull $0x2, %eax
	xorl %edx, %edx
	movl $21, %ebx
	idivl %ebx
	incl %edx
	movl $a_mas, %eax
	pushl (%eax, %edx, 4) # Last argument
	movl $N, %edx
	incl %edx
	pushl (%eax, %edx, 4) # Second argument
	pushl (%eax)
	pushl $format_output
	call printf
	addl $0xC, %esp

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

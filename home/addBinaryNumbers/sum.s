.section .rodata

.section .bss

.section .text
.globl addBinaryNumbers
.type addBinaryNumbers, @function
addBinaryNumbers:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ len_first, -4
	.equ len_second, -8

	# Saving registers
	pushl %esi
	pushl %edi
	pushl %ebx

	# Initializing variables

	# Main part

	# Restoring registers
	popl %ebx
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

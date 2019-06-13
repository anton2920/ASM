.section .rodata
format_input:
	.asciz "%d"
format_output:
	.asciz "Type N: "
format_answer:
	.asciz "The %d element of Fibonacci sequence is %d\n"
format_error:
	.asciz "Error! N must be positive!\n"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ VAR_A, 4
	subl $VAR_A, %esp # Acquiring space in -4(%ebp)

	# I/O flow && VarCheck
do_while:
	pushl $format_output
	call printf
	addl $0x4, %esp

	leal VAR_A(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl VAR_A(%ebp), %edi

	cmpl $0x0, %edi
	jle n_error

	# Main part
	xorl %eax, %eax # 2 prev
	xorl %ebx, %ebx
	incl %ebx # 1 prev
	xorl %ecx, %ecx
	incl %ecx # counter
	xorl %edx, %edx
	incl %edx

while:
	cmpl %ecx, %edi
	je while_end

	xorl %edx, %edx # curr

	addl %eax, %edx
	addl %ebx, %edx

	movl %ebx, %eax
	movl %edx, %ebx

	incl %ecx

	jmp while

while_end:
	pushl %edx
	pushl %edi
	pushl $format_answer
	call printf
	addl $0xC, %esp

	jmp exit

n_error:
	pushl $format_error
	call printf
	addl $0x4, %esp

	jmp do_while

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.section .data
format_input:
	.asciz "%d"
format_output_1:
	.asciz "Type a number: "
format_output_2:
	.asciz "Type a new number base: "
format_answer:
	.asciz "The number %d in base-%d equals to %d\n"

.section .bss

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x8, %esp # Acquiring space for two variables
	.equ VAR_A, -4
	.equ VAR_B, -8

	# I/O flow
	pushl $format_output_1
	call printf
	addl $0x4, %esp

	leal VAR_A(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal VAR_B(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part
	pushl VAR_B(%ebp)
	pushl VAR_A(%ebp)
	call to_base
	addl $0x8, %esp

	pushl %eax
	pushl VAR_B(%ebp)
	pushl VAR_A(%ebp)
	pushl $format_answer
	call printf
	addl $0xC, %esp

exit:
	# Exitting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type to_base, @function
to_base:
	# Initializing functio's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	xorl %ecx, %ecx
	incl %ecx
	xorl %esi, %esi

	# Main part
while:
	cmpl $0x0, %eax
	je while_end

	xorl %edx, %edx
	idivl %ebx

	imull %ecx, %edx
	addl %edx, %esi

	imull $0xA, %ecx

	jmp while

while_end:
	movl %esi, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

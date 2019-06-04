.section .rodata
format_input:
	.asciz "%d"
format_output_1:
	.asciz "Type element A: "
format_output_2:
	.asciz "Type step B: "
format_output_3:
	.asciz "Type first element C: "
format_answer_1:
	.asciz "Element A is a part of this arithmetic progression\n"
format_answer_2:
	.asciz "Element A isn't a part of this arithmetic progression\n"

.section .bss

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x4, %esp # Acquiring space in -4(%ebp)

	# I/O flow
	pushl $format_output_1
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	movl -4(%ebp), %eax
	pushl %eax

	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	movl -4(%ebp), %eax
	pushl %eax

	pushl $format_output_3
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	movl -4(%ebp), %eax
	pushl %eax

	# Main part
	popl %ecx
	popl %ebx
	popl %eax

	subl %ecx, %eax
	xorl %edx, %edx

	idivl %ebx

if:
	cmpl $0x0, %edx
	jne not_prog

is_prog:
	pushl $format_answer_1
	call printf
	addl $0x8, %esp
	jmp exit

not_prog:
	pushl $format_answer_2
	call printf
	addl $0x8, %esp

exit:
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.section .rodata
format_input:
	.asciz "%d"
format_output_1:
	.asciz "Type A: "
format_output_2:
	.asciz "Type B: "
format_answer:
	.asciz "The number %d has the biggest sum of its digits (%d)\n"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ var_a, -4 # int
	.equ var_b, -8 # int
	.equ max_sum, -12 # int
	.equ sum, -16 # int
	.equ biggest_num, -20 # int
	subl $0x14, %esp # Acquiring space for five variables

	# I/O flow && VarCheck
do_while_1:
	pushl $format_output_1
	call printf
	addl $0x4, %esp

	leal var_a(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	cmpl $0x0, var_a(%ebp)
	jle do_while_1

do_while_2:
	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal var_b(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	cmpl $0x0, var_b(%ebp)
	jle do_while_2

	movl var_a(%ebp), %eax
	cmpl %eax, var_b(%ebp) # if (b < a)
	jl do_while_2

	# Main part
	movl var_a(%ebp), %ecx
	movl var_b(%ebp), %esi
	movl $-1, max_sum(%ebp)
	movl $0xA, %ebx

for_1:
	cmpl %esi, %ecx # if (c > s)
	jg for_1_end

	movl %ecx, %eax
	movl $0x0, sum(%ebp)

for_sum:
	cmpl $0x0, %eax
	je for_sum_end

	xorl %edx, %edx
	idivl %ebx

	addl %edx, sum(%ebp)

	jmp for_sum

for_sum_end:
	movl sum(%ebp), %edx
	movl max_sum(%ebp), %edi

	incl %ecx

if:
	cmpl %edi, %edx # if (sum > curr_sum)
	jle for_1

	movl %edx, max_sum(%ebp)
	decl %ecx
	movl %ecx, biggest_num(%ebp)
	incl %ecx

	jmp for_1

for_1_end:
	movl max_sum(%ebp), %eax
	movl biggest_num(%ebp), %ebx

	# Final output
	pushl %eax
	pushl %ebx
	pushl $format_answer
	call printf
	addl $0xC, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

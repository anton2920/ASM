.section .rodata
format_input:
	.asciz "%lf"
format_output:
	.asciz "Type x: "
format_answer:
	.asciz "Answer: %6.3lf\n"
int_5:
	.long 5
int_2:
	.long 2
int_3:
	.long 3

.section .bss
	.equ SIZEOFDOUBLE, 8
	.lcomm LF_VAL, SIZEOFDOUBLE

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# I/O flow
	pushl $format_output
	call printf
	addl $0x4, %esp

	pushl $LF_VAL
	pushl $format_input
	call scanf
	addl $0x8, %esp

main_p:
	# Main part. FPU
	finit
	fldz
	fldl LF_VAL
	fcomip %st(1), %st(0) # if
	ja second_branch

first_branch:
	fstp %st(0)
	fildl int_5
	jmp final_output

second_branch:
	fstp %st(0)
	fld1
	fldl LF_VAL
	fcomip %st(1), %st(0)
	ja third_branch

	# x³ + 1
	fldl LF_VAL
	fldl LF_VAL
	fmulp
	fldl LF_VAL
	fmulp
	faddp

	# 2x + 3
	fldl LF_VAL
	fildl int_2
	fmulp
	fildl int_3
	faddp

	fdivrp
	jmp final_output

third_branch:
	fstp %st(0)
	fildl int_5

	# ln(x)
	fldln2
	fldl LF_VAL
	fyl2x

	# 5ln(x)
	fmulp

final_output:
	subl $0x8, %esp

	# Final output 
	fstpl (%esp)
	pushl $format_answer
	call printf
	addl $0xC, %esp

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

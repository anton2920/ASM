.section .rodata
format_input:
	.asciz "%lf"
format_output:
	.asciz "Type x: "
format_answer:
	.asciz "f(x) = %6.3lf\n"
int_2:
	.long 2
int_6:
	.long 6
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

	# Main part. FPU
	finit

	# x - 6	
main_p:
	fildl int_6
	fldl LF_VAL
	fsubp %st(0), %st(1)

	# 2x² - (x - 6)
	fldl LF_VAL
	fldl LF_VAL
	fmulp
	fildl int_2
	fmulp
	fmulp

	# 1 / 3
	fildl int_3
	fld1
	fdivp

	# Preparing calling pow()
	subl $SIZEOFDOUBLE, %esp
	fstpl (%esp) # power

	subl $SIZEOFDOUBLE, %esp
	fstpl (%esp) # base

	call pow
	addl $0x10, %esp

	fld1
	faddp

	# Final output
	subl $SIZEOFDOUBLE, %esp
	fstpl (%esp)
	pushl $format_answer
	call printf
	addl $0xC, %esp

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt


.type pow, @function
pow:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	fldl 16(%ebp)
	fldl 8(%ebp)

	# Main part
	fyl2x

	fld %st(0)
	frndint
	fsubr %st(0), %st(1)
	fxch %st(1)
	f2xm1
	fld1
	faddp
	fscale
	fstp %st(1)

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.section .rodata
format_input:
	.asciz "%lf"
format_output:
	.asciz "Type a member of a sequence («0» to finish): "
format_answer:
	.asciz "Geometric mean is equals to %.2lf\n"
format_error:
	.asciz "Error! Number must be positive!\n"
new_presicion:
	.byte 0x7f, 0x02

.section .data
PROD:
	.double 1.0

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ VAR_CNT, -4
	.equ DVAR_CURR, -12
	subl $0xC, %esp # Acquiring space for two variables

	# Initializing variables
	movl $0x0, VAR_CNT(%ebp)

	# Main part. FPU
	finit
	fldcw new_presicion # Change presicion from double-extended to double

	fldl PROD

do_while:
	pushl $format_output
	call printf
	addl $0x4, %esp

	leal DVAR_CURR(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	fldl (%esp)

	fldz
	fcomip %st(1)
	jz do_while_end
	jnc neg_exception

	fmulp %st(1)

	addl $0x1, VAR_CNT(%ebp)

	jmp do_while

neg_exception:
	pushl $format_error
	call printf
	addl $0x4, %esp

	jmp do_while

do_while_end:
	fstp %st(0)
	fild VAR_CNT(%ebp)
	fld1
	fdivp %st(0), %st(1) # 1 / VAR_CNT

	subl $0x8, %esp
	fstpl (%esp)

	subl $0x8, %esp
	fstpl (%esp)

	call pow
	addl $0x10, %esp

	subl $0x8, %esp
	fstpl (%esp)
	pushl $format_answer
	call printf
	addl $0x14, %esp

	# Exiting
	xorl %eax, %eax
	incl %eax
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
	faddp %st(1)

	fscale
	fstp %st(1)

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

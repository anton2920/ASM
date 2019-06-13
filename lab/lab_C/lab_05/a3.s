.section .rodata
format_input:
	.asciz "%lf"
format_output_1:
	.asciz "Type x: "
format_output_2:
	.asciz "Type y: "
format_answer_1:
	.asciz "This dot is in this area\n"
format_answer_2:
	.asciz "This dot isn't in this area\n"
precision_val:
	.byte 0x7F, 0x02

.section .bss
.equ SIZE_OF_DOUBLE, 8
.lcomm VAR_X, SIZE_OF_DOUBLE
.lcomm VAR_Y, SIZE_OF_DOUBLE

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# I/O flow
	pushl $format_output_1
	call printf
	addl $0x4, %esp

	pushl $VAR_X
	pushl $format_input
	call scanf
	addl $0x8, %esp

	pushl $format_output_2
	call printf
	addl $0x4, %esp

	pushl $VAR_Y
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part. FPU
	finit
	fldcw precision_val # Change precision to double (from standard double-extended)

	# x²
	fldl VAR_X
	fld %st(0)
	fmulp %st(1)

	fldl VAR_Y

if_1:
	fcomip %st(1)
	jc else
	jz else

	# e ^ x
	fstp %st(0)
	fldl VAR_X
	subl $0x8, %esp
	fstl (%esp)
	call e_pow

	fldl VAR_Y

if_2:
	fcomip %st(1)
	jnc else
	jz else

	fstp %st(0)

	# e ^ (-x)
	fstp %st(0)
	fldl VAR_X
	fchs
	subl $0x8, %esp
	fstl (%esp)
	call e_pow

	fldl VAR_Y

if_3:
	fcomip %st(1)
	jnc else
	jz else

	fstp %st(0)

	pushl $format_answer_1
	call printf
	addl $0x4, %esp

	jmp exit

else:
	pushl $format_answer_2
	call printf
	addl $0x4, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type pow, @function
e_pow:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	fldl 8(%ebp) # power

	# Main part
	fldl2e # load log2(e)
	fmulp %st(1)

	fld %st(0) # make a copy
	frndint # round it to nearest integer
	fsubr %st(0), %st(1) # find a difference
	fxch %st(1) # change values 
	f2xm1
	fld1
	faddp
	fscale
	fstp %st(1)

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

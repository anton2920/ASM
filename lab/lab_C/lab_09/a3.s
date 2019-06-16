.section .rodata
format_input:
	.asciz "%lf"
format_output_1:
	.asciz "Type the «start» point: "
format_output_2:
	.asciz "Type step: "
format_output_3:
	.asciz "Type the «end» point: "
format_table:
	.asciz "|\t%.1lf\t|\t%lf\t|\n"
format_table_head:
	.asciz "\n|\tx\t|\t   f(x)\t\t|\n"
format_line:
	.asciz " ----------------------------------------\n"
int_4:
	.long 4
precision:
	.byte 0x7f, 0x02

.equ SIZE_OF_DOUBLE, 8
.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ start, -8 # double
	.equ step, -16 # double
	.equ end, -24 # double
	.equ curr, -32 # double
	.equ func, -40 # double
	subl $0x28, %esp # Acquiring space for five variables

	# Main part. FPU
	finit
	fldcw precision

	pushl $format_output_1
	call printf
	addl $0x4, %esp

	leal start(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

do_while_1:
	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal step(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	fldz
	fldl step(%ebp)
	fcomip %st(1) # if (step == 0.0)
	jz do_while_1

do_while_2:
	pushl $format_output_3
	call printf
	addl $0x4, %esp

	leal end(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	fldl step(%ebp)
	fldz
	fcomip %st(1) # if (0 < step)
	jc do_while_2_check

	fstp %st(0)

	fldl end(%ebp)
	fldl start(%ebp)
	fcomip %st(1) # if (start < end)
	jc do_while_2

do_while_2_check:
	pushl $format_table_head
	call printf
	addl $0x4, %esp

	pushl $format_line
	call printf
	addl $0x4, %esp

	fldl start(%ebp)
	fstpl curr(%ebp)

main_while:
	fldl curr(%ebp)

	fldl end(%ebp)
	fcomip %st(1) # if (end < curr)
	jc main_while_end

if_1:
	fldz
	fcomip %st(1) # if (0 < curr)
	jc if_2

	fldz
	fstpl func(%ebp)

	fstp %st(0)

	jmp main_while_cnt

if_2:
	fld1
	fcomip %st(1) # if (1 <= curr)
	jc else
	jz else

	fild int_4
	faddp %st(1)
	fld1
	fdivp %st(1)

	fstpl func(%ebp)

	jmp main_while_cnt

else:
	subl $SIZE_OF_DOUBLE, %esp
	fstpl (%esp)
	call exp
	addl $SIZE_OF_DOUBLE, %esp

	fstpl func(%ebp)

main_while_cnt:
	fldl curr(%ebp)
	fldl func(%ebp)

	subl $SIZE_OF_DOUBLE, %esp
	fstpl (%esp)

	subl $SIZE_OF_DOUBLE, %esp
	fstpl (%esp)

	pushl $format_table
	call printf
	addl $0x14, %esp

	pushl $format_line
	call printf
	addl $0x4, %esp

	fldl step(%ebp)
	fldl curr(%ebp)
	faddp %st(1)

	fstpl curr(%ebp)

	jmp main_while

main_while_end:
exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type exp, @function
exp:
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

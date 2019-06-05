.section .rodata
format_output:
	.asciz "Welcome to assemply floating-point\n   value's function tabulator!\n\n"
format_table:
	.asciz "|\t%.1lf\t|\t%lf\t|\n"
format_table_head:
	.asciz "|\tx\t|\t   f(x)\t\t|\n"
format_function:
	.asciz "\nf(x) = sin(x) + cos(x / 2) * x\n\n"
format_line:
	.asciz " ----------------------------------------\n"

.section .data
VAR_X:
	.double -1.0
increment:
	.double 0.1
int_2:
	.long 2

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# I/O flow
	pushl $format_output
	call printf
	addl $0x4, %esp

	pushl $format_function
	call printf
	addl $0x4, %esp

	pushl $format_line
	call printf
	addl $0x4, %esp

	pushl $format_table_head
	call printf
	addl $0x4, %esp

	pushl $format_line
	call printf
	addl $0x4, %esp

	# Main part. FPU
	finit
	fldl VAR_X

do_while_loop:

	# cos(x / 2)
	fld %st(0)
	fidiv int_2
	fcos

	# cos (x / 2) * x
	fld %st(1)
	fmulp

	# sin(x)
	fld %st(1)
	fsin

	# sin(x) + cos(x / 2) * x
	faddp

	# Printing
	subl $0x8, %esp
	fstpl (%esp)

	subl $0x8, %esp
	fstl (%esp)

	pushl $format_table
	call printf
	addl $0x14, %esp

	pushl $format_line
	call printf
	addl $0x4, %esp

	fld1
	fcomip %st(1)
	jc exit

	faddl increment

	jmp do_while_loop

do_while_end:
exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

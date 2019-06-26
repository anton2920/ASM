.section .rodata
format_input_1:
	.asciz "%d"
format_input_2:
	.asciz "%lf"
format_output:
	.asciz "Choose function: \n\t1) (1 / (2x + 7y)) + 3y²\n\t2) sqrt(9x² + 1 / y) * cos(x)"
format_output_1:
	.asciz "x: Type the «start» point: "
format_output_2:
	.asciz "x: Type step: "
format_output_3:
	.asciz "x: Type the «end» point: "
format_output_4:
	.asciz "y: Type the «start» point: "
format_output_5:
	.asciz "y: Type step: "
format_output_6:
	.asciz "y: Type the «end» point: "
format_table:
	.asciz "|\t%.1lf\t|\t%.1lf\t|\t%lf\t|\n"
format_table_head:
	.asciz "\n|\tx\t|\ty\t|\t   f(x)\t\t|\n"
precision:
	.byte 0x7F, 0x02

.section .data
var_flag:
	.long 0x0

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ x_left, -8 # double
	.equ x_right, -16 # double
	.equ x_step, -24 # double
	.equ x_curr, -32 # double
	.equ x_func, -40 # double

	.equ y_left, -48 # double
	.equ y_right, -56 # double
	.equ y_step, -64 # double
	.equ y_curr, -72 # double
	.equ y_func, -80 # double
	subl $80, %esp # Acquiring spavce for ten variables

	# Initializing variables

	# Main part. FPU
	fstcw precision # Change precision from double-extended to double

do_while_1:
	pushl $format_output
	call printf
	addl $0x4, %esp

	pushl $var_flag
	pushl $format_input
	call scanf
	addl $0x8, %esp

if_1:
	cmpl $0x1, var_flag
	jne if_1_and

	jmp next_input

if_1_and:
	cmpl $0x2, var_flag
	jne do_while_1

next_input:
	pushl $format_output_1
	call printf
	addl $0x4, %esp


exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type f1, @function
f1:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type f2, @function
f2:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret
	
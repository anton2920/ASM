.section .rodata
format_input:
	.asciz "%d"
format_output_1:
	.asciz "Type the population: "
format_output_2:
	.asciz "Type the population rate: "
format_output_3:
	.asciz "Type the «start» year: "
format_output_4:
	.asciz "Type the «end» year: "
format_year:
	.asciz "Year %d: population is equals to %.0lf\n"
format_tri:
	.asciz "\nThe population will triple in %u years\n"
format_not_tri:
	.asciz "\nThe population will never triple :(\n"
format_dead:
	.asciz "Year %d: population is dead ×_×\n"
presicion:
	.byte 0x7f, 0x02
hundred:
	.long 100
int_three:
	.long 3
format_newline:
	.asciz "\n"
format_inf:
	.asciz "The population will triple in countably infinite number of years\n"

.section .bss
.equ SIZE_OF_DOUBLE, 8
.lcomm dpop, SIZE_OF_DOUBLE

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ population, -4
	.equ rate, -8
	.equ start_year, -12
	.equ end_year, -16
	subl $0x14, %esp # Acquiring space for five variables

	# I/O flow && VarCheck
do_while_1:
	pushl $format_output_1
	call printf
	addl $0x4, %esp

	leal population(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	cmpl $0x0, population(%ebp)
	jle do_while_1

do_while_2:
	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal rate(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	cmpl $100, rate(%ebp)
	jg do_while_2

	cmpl $-100, rate(%ebp)
	jl do_while_2

do_while_3:
	pushl $format_output_3
	call printf
	addl $0x4, %esp

	leal start_year(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	cmpl $0x0, start_year(%ebp)
	jle do_while_3

do_while_4:
	pushl $format_output_4
	call printf
	addl $0x4, %esp

	leal end_year(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	cmpl $0x0, end_year(%ebp)
	jle do_while_4
	movl start_year(%ebp), %eax
	cmpl %eax, end_year(%ebp)
	jle do_while_4

	pushl $format_newline
	call printf
	addl $0x4, %esp

	# Main part. FPU
	finit
	fldcw presicion # Change presicion from double-extended to double

	movl start_year(%ebp), %ecx
	fild population(%ebp)
	fstl dpop

main_for_loop:
	cmpl end_year(%ebp), %ecx # if (c > end_year)
	jg main_for_loop_end

	fld1
	fldl dpop
	fcomip %st(1)
	jc extincton

	fstp %st(0)

	# Saving registers
	pushl %ecx
	fstl dpop

	subl $SIZE_OF_DOUBLE, %esp
	fstpl (%esp)

	pushl %ecx
	pushl $format_year
	call printf
	addl $0x10, %esp

	# Restoring registers
	popl %ecx

	fild rate(%ebp) # rate
	fild hundred # $100
	fdivrp %st(1) # rate / 100
	fld1 # $1
	faddp %st(1) # 1 + (rate / 100)
	fldl dpop # population
	fmulp %st(1) # population + (population * (rate / 100)) = population * (1 + (rate / 100)

	incl %ecx

	jmp main_for_loop

main_for_loop_end:
	cmpl $0x0, rate(%ebp)
	jle wont_triple
	
	# Now, find out about «triplets»
	xorl %ecx, %ecx
	fild population(%ebp)
	fstpl dpop

while_loop:
	fldl dpop
	fild population(%ebp)
	fdivrp %st(1)
	fild int_three
	fcomip %st(1)
	jc while_loop_end
	jz while_loop_end
	
	fstp %st(0)

	fild rate(%ebp) # rate
	fild hundred # $100
	fdivrp %st(1) # rate / 100
	fld1 # $1
	faddp %st(1) # 1 + (rate / 100)
	fldl dpop # population
	fmulp %st(1) # population + (population * (rate / 100)) = population * (1 + (rate / 100)

	fstpl dpop
	addl $0x1, %ecx
	jc infinite

	jmp while_loop

while_loop_end:
will_triple:
	pushl %ecx
	pushl $format_tri
	call printf
	addl $0x8, %esp

	jmp exit

infinite:
	pushl $format_inf
	call printf
	addl $0x4, %esp

	jmp exit

extincton:
	pushl %ecx
	pushl $format_dead
	call printf
	addl $0x8, %esp

wont_triple:
	pushl $format_not_tri
	call printf
	addl $0x4, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

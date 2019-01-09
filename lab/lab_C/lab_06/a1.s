.section .data
format_input:
	.ascii "%d\0"
format_output:
	.ascii "Type the number of the month: \0"
format_answer:
	.ascii "It's %s, %s\n\0"
format_error:
	.ascii "Error! There is no such month!\n\0"
str_january:
	.ascii "January\0"
str_february:
	.ascii "February\0"
str_march:
	.ascii "March\0"
str_april:
	.ascii "April\0"
str_may:
	.ascii "May\0"
str_june:
	.ascii "June\0"
str_july:
	.ascii "July\0"
str_august:
	.ascii "August\0"
str_september:
	.ascii "September\0"
str_october:
	.ascii "October\0"
str_november:
	.ascii "November\0"
str_december:
	.ascii "December\0"
str_winter:
	.ascii "Winter\0"
str_spring:
	.ascii "Spring\0"
str_summer:
	.ascii "Summer\0"
str_autumn:
	.ascii "Autumn\0"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x4, %esp # Acquiring space in -4(%ebp)

	# I/O flow
	pushl $format_output
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part
	popl %eax

switch:
	cmpl $0x1, %eax
	je case_1

	cmpl $0x2, %eax
	je case_2

	cmpl $0x3, %eax
	je case_3

	cmpl $0x4, %eax
	je case_4

	cmpl $0x5, %eax
	je case_5

	cmpl $0x6, %eax
	je case_6

	cmpl $0x7, %eax
	je case_7

	cmpl $0x8, %eax
	je case_8

	cmpl $0x9, %eax
	je case_9

	cmpl $0xA, %eax
	je case_10

	cmpl $0xB, %eax
	je case_11

	cmpl $0xC, %eax
	je case_12
	jne default

case_1:
	pushl $str_winter
	pushl $str_january
	jmp switch_end

case_2:
	pushl $str_winter
	pushl $str_february
	jmp switch_end

case_3:
	pushl $str_spring
	pushl $str_march
	jmp switch_end

case_4:
	pushl $str_spring
	pushl $str_april
	jmp switch_end

case_5:
	pushl $str_spring
	pushl $str_may
	jmp switch_end

case_6:
	pushl $str_summer
	pushl $str_june
	jmp switch_end

case_7:
	pushl $str_summer
	pushl $str_july
	jmp switch_end

case_8:
	pushl $str_summer
	pushl $str_august
	jmp switch_end

case_9:
	pushl $str_autumn
	pushl $str_september
	jmp switch_end

case_10:
	pushl $str_autumn
	pushl $str_october
	jmp switch_end

case_11:
	pushl $str_autumn
	pushl $str_november
	jmp switch_end

case_12:
	pushl $str_winter
	pushl $str_december
	jmp switch_end

default: 
	pushl $format_error
	call printf
	addl $0x4, %esp
	jmp exit

switch_end:
	# Final output
	pushl $format_answer
	call printf
	addl $0x8, %esp

exit:
	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

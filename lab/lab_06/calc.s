.section .data
newline:
	.ascii "\n\0"
	.equ len_newline, . - newline
separator:
	.ascii "––––––––––––––––––––––––––––––––––––––\n\0"
	.equ len_separator, . - separator
error_line:
	.ascii "Error! Usage: <int> <sign> <int>\n\0"
	.equ len_error_line, . - error_line
space:
	.ascii " \0"
	.equ len_space, . - space
equals:
	.ascii " = \0"
	.equ len_equals, . - equals
remainder:
	.ascii ", remainder = \0"
	.equ len_remainder, . - remainder

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ first_num, -8
	.equ second_num, -4
	subl $0x8, %esp # Acquiring space for two variables

	# Initializing variables
	.equ ARGC, 0
	.equ ARGV_1, 8
	.equ ARGV_2, 12

	movl ARGC(%ebp), %ecx
	decl %ecx
	leal ARGV_1(%ebp), %eax

	# Main part
	cmpl $0x0, %ecx
	jle error

	cmpl $0x3, %ecx
	jne error

	# VarCheck
	xorl %ecx, %ecx
	movl ARGV_2(%ebp), %ebx
	movb (%ebx), %cl

	cmpb $'+', %cl
	je first_number

	cmpb $'-', %cl
	je first_number

	cmpb $'*', %cl
	je first_number

	cmpb $'/', %cl
	je first_number

	cmpb $'^', %cl
	je first_number
	jne error

first_number:
	# Saving registers
	pushl %eax

	pushl $len_separator
	pushl $separator
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %eax

	# Saving registers
	pushl %eax

	pushl (%eax)
	call atoi
	addl $0x4, %esp

	movl %eax, first_num(%ebp)

	pushl %eax
	call iprint
	addl $0x4, %esp

	pushl $len_space
	pushl $space
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %eax

detect_sign:
	addl $0x4, %eax

	xorl %ecx, %ecx
	movl (%eax), %ebx
	movb (%ebx), %cl

	pushl %ecx # sign

	# Saving registers
	pushl %eax

	pushl %ecx
	call putchar
	addl $0x4, %esp

	pushl $len_space
	pushl $space
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %eax

second_number:
	addl $0x4, %eax

	pushl (%eax)
	call atoi
	addl $0x4, %esp

	movl %eax, second_num(%ebp)

	pushl %eax
	call iprint
	addl $0x4, %esp

	pushl $len_equals
	pushl $equals
	call write
	addl $0x8, %esp

switch_case:
	popl %ecx
	cmpb $'+', %cl
	je plus_sign

	cmpb $'-', %cl
	je minus_sign

	cmpb $'*', %cl
	je mul_sign

	cmpb $'/', %cl
	je div_sign

	cmpb $'^', %cl
	je power_sign

	jmp default_case

plus_sign:
	call summirovaniye
	addl $0x8, %esp

	pushl %eax
	call iprint
	addl $0x4, %esp

	jmp end_switch
	
minus_sign:
	call vichitaniye
	addl $0x8, %esp

	pushl %eax
	call iprint
	addl $0x4, %esp

	jmp end_switch

mul_sign:
	call umnogeniye
	addl $0x8, %esp

	pushl %eax
	call iprint
	addl $0x4, %esp

	jmp end_switch 

div_sign:
	leal first_num(%ebp), %eax
	leal second_num(%ebp), %ebx
	pushl %ebx
	pushl %eax
	call deleniye
	addl $0x8, %esp

	pushl %eax
	call iprint
	addl $0x4, %esp

	pushl $len_remainder
	pushl $remainder
	call write
	addl $0x8, %esp

	movl second_num(%ebp), %eax
	pushl %eax
	call iprint
	addl $0x4, %esp

	jmp end_switch

power_sign:
	call power
	addl $0x8, %esp

	pushl %eax
	call iprint
	addl $0x4, %esp

	jmp end_switch 

default_case:
	jmp error

end_switch:
	pushl $len_newline
	pushl $newline
	call write
	addl $0x8, %esp

	pushl $len_separator
	pushl $separator
	call write
	addl $0x8, %esp

	jmp exit

error:
	pushl $len_error_line
	pushl $error_line
	call write
	addl $0x8, %esp

exit:
	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt
	
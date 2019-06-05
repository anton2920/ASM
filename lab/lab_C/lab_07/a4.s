.equ TRUE, 1
.equ FALSE, 0

.section .rodata
format_input:
	.asciz "%d"
format_output_1:
	.asciz "Type a number: "
format_output_2:
	.asciz "Type a number's base (base <= 9): "
format_answer:
	.asciz "The number %d (base-%d) equals to %d (in base-10)\n"
format_error:
	.asciz "Error! Digits must be less than base!\n"

.section .bss

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x8, %esp # Acquiring space for two variables
	.equ VAR_A, -4
	.equ VAR_B, -8

do_while:
	# I/O flow
	pushl $format_output_2
	call print
	addl $0x4, %esp

	leal VAR_B(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	pushl $format_output_1
	call print
	addl $0x4, %esp

	leal VAR_A(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part
	pushl VAR_B(%ebp)
	pushl VAR_A(%ebp)
	call check_digits
	addl $0x8, %esp

if_digits:
	cmpl $TRUE, %eax
	jne error_digits

ok_digits:
	pushl VAR_B(%ebp)
	pushl VAR_A(%ebp)
	call to_dec
	addl $0x8, %esp

	pushl %eax
	pushl VAR_B(%ebp)
	pushl VAR_A(%ebp)
	pushl $format_answer
	call printf
	addl $0xC, %esp

	jmp exit

error_digits:
	pushl $format_error
	call printf
	addl $0x4, %esp

	jmp do_while

exit:
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type check_digits, @function
check_digits:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	xorl %ecx, %ecx
	movl $0xA, %esi

	# Main part 
while_digits:
	cmpl $0x0, %eax
	je while_digits_end

	xorl %edx, %edx
	idivl %esi

	cmpl %ebx, %edx # if (digit >= base)
	jge 

	jmp while_digits

bad_digits:
	
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
format_error_2:
	.asciz "Error! Wrong base!\n"

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
	# I/O flow && VarCheck
	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal VAR_B(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	cmpl $0x9, VAR_B(%ebp)
	jg error_base

	pushl $format_output_1
	call printf
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

error_base:
	pushl $format_error_2
	call printf
	add $0x4, %esp

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
	jge bad_digits

	jmp while_digits

while_digits_end:
	movl $TRUE, %eax
	jmp check_digits_exit

bad_digits:
	movl $FALSE, %eax

check_digits_exit:
	movl %ebp, %esp
	popl %ebp
	ret
	

.type to_dec, @function
to_dec:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # number
	movl 12(%ebp), %ebx # base
	xorl %ecx, %ecx
	incl %ecx
	movl $0xA, %esi
	xorl %edi, %edi

	# Main part
while_to_dec:
	cmpl $0x0, %eax
	jle while_to_dec_end

	xorl %edx, %edx
	idivl %esi

	imull %ecx, %edx
	addl %edx, %edi

	imull %ebx, %ecx

	jmp while_to_dec

while_to_dec_end:
	movl %edi, %eax

to_dec_exit:
	movl %ebp, %esp
	popl %ebp
	ret

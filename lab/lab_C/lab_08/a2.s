.section .rodata
format_input:
	.asciz "%d"
format_output:
	.asciz "Type number: "
format_answer:
	.asciz "Multiplication of digits: %d\n"

.section .bss

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x4, %esp # Acquiring space in -4(%ebp)

	# I/O flow
do_while:
	pushl $format_output
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl (%esp), %eax

	cmpl $0x0, %eax
	jle do_while

do_while_end:

	# Main part
	movl -4(%ebp), %eax
	pushl %eax
	call count_digits
	addl $0x4, %esp

	xorl %ecx, %ecx

if_less_two:
	cmpl $0x2, %eax
	jl while2_end

	xorl %edx, %edx
	movl $0x2, %ebx
	idivl %ebx
	xorl %ecx, %ecx
	incl %ecx

if_odd_even:
	cmpl $0x0, %edx
	je even_num

odd_num:
	popl %eax
	xorl %edx, %edx
	movl $0xA, %ebx
	idivl %ebx

	jmp while2
	
even_num:
	popl %eax

while2:
	cmpl $0x0, %eax
	je while2_end

	xorl %edx, %edx
	movl $0xA, %ebx
	idivl %ebx

	imull %edx, %ecx

	xorl %edx, %edx
	idivl %ebx

	jmp while2

while2_end:
	# Final output
	pushl %ecx
	pushl $format_answer
	call printf
	addl $0x8, %esp

exit:
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type count_digits, @function
count_digits:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax
	xorl %ecx, %ecx
	movl $0xA, %ebx

	# Main part
while:
	cmpl $0x0, %eax
	je while_end

	xorl %edx, %edx
	idiv %ebx

	incl %ecx

	jmp while
while_end:
	movl %ecx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

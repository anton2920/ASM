.section .data
format_input:
	.ascii "%d\0"
format_output1:
	.ascii "Type the first number: \0"
format_output2:
	.ascii "Type the second number: \0"
format_answer1:
	.ascii "%d - %d = %d\n\0"
format_answer2:
	.ascii "%d / %d = %d, %d %% %d = %d\n\0"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x4, %esp # Acquiring space in -4(%ebp)

	# I/O flow
	pushl $format_output1
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl -4(%ebp), %eax
	pushl %eax # a

	pushl $format_output2
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl -4(%ebp), %eax
	pushl %eax # b

	# Main part
if:
	popl %ebx # b
	popl %eax # a
	movl %eax, %ecx # c = a
	cmpl %ebx, %eax # if (a >= b)
	jge if_true

if_false:
	xorl %edx, %edx # d = 0
	idiv %ebx # %edx = edx:eax % %ebx; %eax = edx:eax / %ebx

	# Final output
	pushl %edx # Remainder
	pushl %ebx # b
	pushl %ecx # a
	pushl %eax # Quotient
	pushl %ebx # b
	pushl %ecx # a
	pushl $format_answer2
	call printf
	addl $0x22, %esp
	jmp end_if

if_true:
	subl %ebx, %eax # b = a - b

	# Final output
	pushl %eax # Ans 
	pushl %ebx # b
	pushl %ecx # a
	pushl $format_answer1
	call printf
	addl $0xC, %esp

end_if:
	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

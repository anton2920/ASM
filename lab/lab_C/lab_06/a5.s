.section .rodata
format_input_1:
	.asciz "%c"
format_input_2:
	.asciz "%d"
format_output_1:
	.asciz "Type orientation: "
format_output_2:
	.asciz "Type first command: "
format_output_3:
	.asciz "Type second command: "
format_answer:
	.asciz "Answer: %c\n"
format_error:
	.asciz "Error! No such orientation!\n"

.section .bss

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x5, %esp # Acquiring space in -5(%ebp)

	# I/O flow 
	pushl $format_output_1
	call printf
	addl $0x4, %esp

	leal -5(%ebp), %eax
	pushl %eax
	pushl $format_input_1
	call scanf
	addl $0x8, %esp

	movb -5(%ebp), %al

	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input_2
	call scanf
	addl $0x8, %esp

	movl -4(%ebp), %eax
	pushl %eax

	pushl $format_output_3
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input_2
	call scanf
	addl $0x8, %esp

	movl -4(%ebp), %eax
	pushl %eax

	# Main part
	popl %ebx # Second command
	popl %eax # First command

	addl %ebx, %eax # First + second

	movb -5(%ebp), %bl
	addl $0x5, %esp
	
switch_case:
	xorl %ecx, %ecx

	cmpb $'N', %bl
	je switch_end

	cmpb $'W', %bl
	je case_W

	cmpb $'S', %bl
	je case_S

	cmpb $'E', %bl
	je case_E

	jmp case_default

case_W:
	incl %ecx
	jmp switch_end

case_S:
	incl %ecx
	incl %ecx
	jmp switch_end

case_E:
	incl %ecx
	incl %ecx
	incl %ecx
	jmp switch_end

case_default:
	pushl $format_error
	call printf
	addl $0x4, %esp
	jmp exit

switch_end:
	addl %ecx, %eax

switch2_case:
	cmpl $0x0, %eax
	je case2_N

	cmpl $0x1, %eax
	je case2_W

	cmpl $0x2, %eax
	je case2_S

	cmpl $-2, %eax
	je case2_S

	cmpl $0x3, %eax
	je case2_E

	cmpl $-1, %eax
	je case2_E

	jmp case2_default

case2_N:
	subl $0x1, %esp
	movb $'N', (%esp)
	jmp switch2_end

case2_W:
	subl $0x1, %esp
	movb $'E', (%esp)
	jmp switch2_end

case2_S:
	subl $0x1, %esp
	movb $'S', (%esp)
	jmp switch2_end

case2_E:
	subl $0x1, %esp
	movb $'W', (%esp)
	jmp switch2_end

case2_default:

switch2_end:

	# Final output
	pushl $format_answer
	call printf
	addl $0x5, %esp

exit:

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.section .data
format_input:
	.ascii "%d\0"
format_output1:
	.ascii "Type first radius: \0"
format_output2:
	.ascii "Type second radius: \0"
format_output3:
	.ascii "Type third radius: \0"
format_answer:
	.ascii "Answer: %d ^ 2 * pi\n\0"

.section .text
.type min_three, @function
.equ first, 8
.equ second, 12
.equ third, 16
# int min_three(int, int, int);
min_three:
	# Initializing funciton's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl first(%ebp), %eax
	movl second(%ebp), %ebx
	movl third(%ebp), %ecx

	# Main part
	cmpl %ebx, %eax # if (a > b)
	jle if_a_1
	jmp if_b_1

if_a_1:
	cmpl %ecx, %eax # if (a > c)
	jle a_min
	jmp c_min

a_min:
	pushl %eax
	jmp return_min

c_min:
	pushl %ecx
	jmp return_min

if_b_1:
	cmpl %ecx, %ebx # if (b < c)
	jle b_min
	jmp c_min

b_min:
	pushl %ebx
	jmp return_min

return_min:
	popl %eax
	movl %ebp, %esp
	popl %ebp
	ret

.globl main
main:
	# Initializing stack frame
	movl %esp, %ebp
	.equ var, -4
	subl $var, %esp # Acquiring space in var(%ebp)

	# I/O flow
	pushl $format_output1
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax

	pushl $format_output2
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax

	pushl $format_output3
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax
	
	# Main part
	call min_three
	addl $0x10, %esp

	# Final output
	pushl %eax
	pushl $format_answer
	call printf
	addl $0xC, %esp

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interupt


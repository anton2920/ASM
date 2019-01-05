.section .data
format_input:
	.ascii "%d\0"
format_output:
	.ascii "Type angle: \0"
format_answer:
	.ascii "Angle: %d, Hours: %d, Minutes: %d\n\0"

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
	movl -4(%ebp), %eax # Angle
	xorl %edx, %edx
	movl $360, %ebx
	idiv %ebx
	movl %edx, %eax # Angle % 360
	xorl %edx, %edx
	movl $30, %ebx
	idiv %ebx # %eax = Angle / 30 — hours
	imul $0x2, %edx # %edx = (Angle / 30) * 2 — minutes
	movl %edx, %ebx
	imul $0x6, %ebx # Angle

	# Final output
	pushl %edx
	pushl %eax
	pushl %ebx
	pushl $format_answer
	call printf
	addl $0xC, %esp

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

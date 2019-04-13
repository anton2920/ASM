.section .rodata
format_input:
	.asciz "%lf"
format_output:
	.asciz "Type the number of bytes: "
format_answer:
	.asciz "Answer: %.2lf GiB = %.2lf MiB = %.2lf KiB = %.2lf B\n"
KiB:
	.long 1024

.section .bss
	.lcomm LF_VAL, 8

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# I/O flow
	pushl $format_output
	call printf
	addl $0x4, %esp

	pushl $LF_VAL
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part 
main_p:

	subl $0x20, %esp

	# FPU
	finit
	fldl LF_VAL
	fstl -8(%ebp)

	fidiv KiB
	fstl -16(%ebp)

	fidiv KiB
	fstl -24(%ebp)

	fidiv KiB
	fstl -32(%ebp)

	# Final output
	pushl $format_answer
	call printf
	addl $0x28, %esp

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

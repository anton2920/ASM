.section .rodata
format_input:
	.asciz "%d"
format_output:
	.asciz "Type N: "
format_output_2:
	.asciz "Type a number: "
format_answer:
	.asciz "Sum is %d\n"

.section .text
.globl _start
_start:
	# Initializing stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ VAR_OLD_S, -4
	.equ VAR_NEW_S, -8
	.equ VAR_N, -12
	.equ VAR_CURR, -16
	subl $0x10, %esp

	# Initializing variables
	movl $0x0, VAR_OLD_S(%ebp)
	movl $0x0, VAR_NEW_S(%ebp)

	# I/O flow
	pushl $format_output
	call printf
	addl $0x4, %esp

	leal VAR_N(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part
	movl VAR_N(%ebp), %ecx

main_loop:
	testl %ecx, %ecx
	jz main_loop_end

	# Saving registers
	pushl %ecx

	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal VAR_CURR(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Restoring registers
	popl %ecx

	decl %ecx

	movl VAR_CURR(%ebp), %eax
	addl %eax, VAR_NEW_S(%ebp)

	testl %eax, %eax
	jnz main_loop

	movl VAR_NEW_S(%ebp), %eax
	movl %eax, VAR_OLD_S(%ebp)
	movl $0x0, VAR_NEW_S(%ebp)

	jmp main_loop

main_loop_end:

	# Final output
	pushl VAR_OLD_S(%ebp)
	pushl $format_answer
	call printf
	addl $0x8, %esp

	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

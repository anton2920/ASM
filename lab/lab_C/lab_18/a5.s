.section .data
format_output:
	.ascii "%d\n\0"

.section .text
.globl _start
_start:
	
	# Initializing stack frame
	movl %esp, %ebp
	subl $0xC, %esp # Acquiring space for three variables

	# Initializing variables
	.equ x, -4
	.equ p, -8
	.equ i, -12
	movl $0xA, x(%ebp) # x = 10
	movl $0x1, i(%ebp) # i = 1

for_loop:
	movl i(%ebp), %ecx
	cmpl x(%ebp), %ecx
	jg for_loop_end

	leal i(%ebp), %eax
	movl %eax, p(%ebp)

	movl p(%ebp), %eax
	pushl (%eax)
	pushl $format_output
	call printf
	addl $0x8, %esp

	incl i(%ebp)

	jmp for_loop

for_loop_end:
	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.section .rodata
format_output:
	.asciz "y(%d) = %d\n"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# Initializing variables
	xorl %ecx, %ecx
	incl %ecx
	incl %ecx
	incl %ecx # c = 3

	# Main part
for_loop:
	cmpl $0x1E, %ecx
	jg for_loop_end

	xorl %esi, %esi
	incl %esi
	incl %esi # s = 2

	subl %ecx, %esi # s -= c

	xorl %eax, %eax

	movl %esi, %ebx
	imull %esi, %ebx # b = s²

	addl %ebx, %eax
	imull $0x3, %eax
	incl %eax # a = 3s² + 1

	imull %esi, %ebx # b = s³

	addl %ebx, %eax # a = s³ + 3s² + 1

	pushl %ecx

	pushl %eax
	pushl %ecx
	pushl $format_output
	call printf
	addl $0xC, %esp

	popl %ecx

	incl %ecx
	incl %ecx
	incl %ecx # c += 3

	jmp for_loop

for_loop_end:

	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

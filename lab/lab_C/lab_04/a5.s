.section .data
format_input:
	.ascii "%d\0"
format_output1:
	.ascii "Type hours: \0"
format_output2:
	.ascii "Type minutes: \0"
format_output3:
	.ascii "Type seconds: \0"
format_output4:
	.ascii "Type additional hours: \0"
format_output5: 
	.ascii "Type additional minutes: \0"
format_output6: 
	.ascii "Type additional seconds: \0"
format_answer:
	.ascii "Answer: %d:%d:%d\n\0"

.section .text
.globl _start
_start:
	# Intitializing stack frame
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
	pushl %eax

	pushl $format_output2
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl -4(%ebp), %eax
	pushl %eax

	pushl $format_output3
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl -4(%ebp), %eax
	pushl %eax

	pushl $format_output4
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl -4(%ebp), %eax
	pushl %eax

	pushl $format_output5
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl -4(%ebp), %eax
	pushl %eax

	pushl $format_output6
	call printf
	addl $0x4, %esp

	leal -4(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl -4(%ebp), %eax
	pushl %eax

	# Main part
	# %ebx — minutes, %eax — seconds, %esi — add h., %edi — add m., %edx — add s.;
	popl %edx # add s.
	popl %edi # add m.
	popl %esi # add h.
	popl %eax # s.
	popl %ebx # m.
	# -4(%ebp) # h.

	addl %edx, %eax
	xorl %edx, %edx
	movl $60, %ecx
	idiv %ecx
	pushl %edx # -12(%ebp)
	addl %eax, %ebx
	xorl %edx, %edx
	addl %edi, %ebx
	movl %ebx, %eax
	idiv %ecx
	pushl %edx # -16(%ebp)
	addl %eax, %esi
	movl -8(%ebp), %eax
	addl %esi, %eax
	xorl %edx, %edx
	movl $24, %ecx
	idiv %ecx
	pushl %edx # -20(%ebp)

	# Final output
	pushl $format_answer
	call printf
	addl $0xF, %esp

	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

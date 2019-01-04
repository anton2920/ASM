.global sum

.section .text

sum:
	movl %edi, %eax
	addl %esi, %eax
	ret

.section .data
value1:
	.float 12.34, -45.67, 89.01, 23.45
value2:
	.double -12.34, 45.67

.section .bss
.lcomm buffer_s, 8
.lcomm buffer_d, 16

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# SSE (SSE2)
	movups value1, %xmm0
	movupd value2, %xmm1
	movups %xmm0, buffer_s
	movupd %xmm1, buffer_d

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80

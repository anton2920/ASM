.equ sizeof_int, 4
.equ first_arg, sizeof_int + sizeof_int
.equ second_arg, first_arg + sizeof_int
.equ third_arg, second_arg + sizeof_int

.equ STDIN, 0

.section .rodata
format_output:
	.asciz "Type string (up to %d characters): "
format_answer:
	.asciz "String copied: %s\n"

.section .bss
.equ sizeof_buf, 500
.lcomm buf1, sizeof_buf
.lcomm buf2, sizeof_buf

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# I/O flow
	pushl $sizeof_buf
	pushl $format_output
	call printf
	addl $0x8, %esp

	pushl stdout
	call fflush
	addl $0x4, %esp

	pushl $sizeof_buf
	pushl $buf1
	pushl $STDIN
	call read
	addl $0xC, %esp

	# leal buf1, %esi
	# movl $0x0, -1(%esi, %eax, 1)
	movl $0x0, buf1 - 1(%eax)

	# Main part
	pushl %eax
	pushl $buf1
	pushl $buf2
	call lstrncpy
	addl $0xC, %esp

	# Final output
	pushl $buf2
	pushl $format_answer
	call printf
	addl $0x8, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type lstrncpy, @function
lstrncpy:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %esi
	pushl %edi

	# Initializing variables
	movl first_arg(%ebp), %edi
	movl second_arg(%ebp), %esi
	movl third_arg(%ebp), %ecx
	movl %ecx, %edx # Save size

	# Main part. SSE (SSE2)
	sarl $0x4, %ecx # Shift length by four (div by 16)

while:
	test %ecx, %ecx
	jz while_end

	movupd (%esi), %xmm0
	movupd %xmm0, (%edi)

	addl $0x10, %esi
	addl $0x10, %edi

	decl %ecx

	jmp while

while_end:
	movl %edx, %ecx
	andl $0xF, %ecx
	
	cld
	rep movsl

	movl %edx, %ecx
	andl $0x3, %ecx

	rep movsb

	# Returning value
	movl first_arg(%ebp), %eax

	# Restoring registers
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type read, @function
.equ SYS_READ, 3
read:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Syscall
	movl $SYS_READ, %eax
	movl first_arg(%ebp), %ebx
	movl second_arg(%ebp), %ecx
	movl third_arg(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

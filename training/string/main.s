.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.section .rodata
hello:
	.asciz "This is the test program for string-operating instructions!\n\n"
	.equ len_hello, . - hello
output_1:
	.asciz "Type first string: "
	.equ len_output_1, . - output_1
output_2:
	.asciz "Type second string: "
	.equ len_output_2, . - output_2


.section .bss
.equ sizeof_buf, 500
.equ sizeof_int

.lcomm buf1, sizeof_buf
.lcomm buf1, sizeof_buf
.lcomm buf3, sizeof_buf

.lcomm len_buf1, sizeof_int
.lcomm len_buf2, sizeof_int

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# Initializing varaibles

	# I/O flow
	pushl $len_hello
	pushl $hello
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $len_output_1
	pushl $output_1
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $sizeof_buf
	pushl $buf1
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl %eax, len_buf1

	# Main part

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

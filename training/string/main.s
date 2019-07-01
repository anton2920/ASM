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

format_length_1:
	.asciz "\nLenght of the first string: %d (correct: %d)\n"
format_length_2:
	.asciz "Length of the second string: %d (correct: %d)\n"
format_result_of_cmp:
	.asciz "\nResult of strings comparison: %d\n\n"
format_third_buf:
	.asciz "The third buffer contents: %s\n"

output_fin:
	.asciz "\nThat's all for now. Now, go and read next chapters of «Professional assembly language»\n"
	.equ len_output_fin, . - output_fin

.section .bss
.equ sizeof_buf, 500
.equ sizeof_int, 4

.lcomm buf1, sizeof_buf
.lcomm buf2, sizeof_buf
.lcomm buf3, sizeof_buf

.lcomm len_buf1, sizeof_int
.lcomm len_buf2, sizeof_int

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

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
	leal buf1, %esi

	pushl $len_output_2
	pushl $output_2
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $sizeof_buf
	pushl $buf2
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl %eax, len_buf2
	leal buf2, %esi

	# Main part

	# Strlen test
	pushl $buf1
	call lstrlen
	addl $0x4, %esp

	pushl len_buf1
	pushl %eax
	pushl $format_length_1
	call printf
	addl $0xC, %esp

	pushl $buf2
	call lstrlen
	addl $0x4, %esp

	pushl len_buf2
	pushl %eax
	pushl $format_length_2
	call printf
	addl $0xC, %esp

	# Strcmp test
	pushl $buf2
	pushl $buf1
	call lstrcmp
	addl $0x8, %esp

	pushl %eax
	pushl $format_result_of_cmp
	call printf
	addl $0x8, %esp

	# Strcpy test
	pushl $buf1
	pushl $buf3
	call lstrcpy
	addl $0x8, %esp

	pushl $buf3
	pushl $format_third_buf
	call printf
	addl $0x8, %esp

	pushl $buf2
	pushl $buf3
	call lstrcpy
	addl $0x8, %esp

	pushl $buf3
	pushl $format_third_buf
	call printf
	addl $0x8, %esp

	# Final output
	pushl $len_output_fin
	pushl $output_fin
	pushl $STDOUT
	call write
	addl $0xC, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

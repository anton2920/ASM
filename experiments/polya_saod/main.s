.include "constants.s"

.section .rodata
file_name:
	.asciz "test.txt"
out_name:
	.asciz "out.txt"
error_msg:
	.asciz "Some error occured!\n"
	.equ len_error_msg, . - error_msg

.section .bss
.equ BUFSIZE, 500
.lcomm BUF, BUFSIZE

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ fd, -4 # int
	.equ fd_out, -8 # int
	subl $0x8, %esp # Acquiring space for two variables

	# Initializing variables

	# Main part
	pushl $STD_PERMS
	pushl $O_RDONLY
	pushl $file_name
	call open
	addl $0xC, %esp

	testl %eax, %eax
	js error

	movl %eax, fd(%ebp)

	pushl $STD_PERMS
	pushl $O_WRTRUNC
	pushl $out_name
	call open
	addl $0xC, %esp

	testl %eax, %eax
	js error

	movl %eax, fd_out(%ebp)

	pushl fd(%ebp)
	pushl $BUFSIZE
	pushl $BUF
	call getline
	addl $0xC, %esp

	pushl %edx
	pushl $BUF
	pushl fd_out(%ebp)
	call write
	addl $0xC, %esp

main_loop:
	pushl $0x0
	pushl $SEEK_SET
	pushl fd_out(%ebp)
	call lseek
	addl $0xC, %esp

	pushl fd(%ebp)
	pushl $BUFSIZE
	pushl $BUF
	call getline
	addl $0xC, %esp

	testl %eax, %eax
	jz main_loop_end

	pushl %edx
	pushl $BUF
	pushl fd_out(%ebp)
	call write
	addl $0xC, %esp

	jmp main_loop

main_loop_end:
	pushl fd(%ebp)
	call close
	addl $0x4, %esp

	pushl fd_out(%ebp)
	call close
	addl $0x4, %esp

	jmp exit

error:
	pushl $len_error_msg
	pushl $error_msg
	pushl $STDERR
	call write
	addl $0xC, %esp

exit:
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type getline, @function
getline:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	xorl %ecx, %ecx

	# Main part
getline_main_loop:
	cmpl second_arg(%ebp), %ecx
	jg getline_main_loop_end

	movl first_arg(%ebp), %edx # Buf

	# Saving registers
	pushl %ecx
	pushl %edx

	pushl $0x1
	leal (%edx, %ecx), %eax
	pushl %eax
	pushl third_arg(%ebp)
	call read
	addl $0xC, %esp

	# Restoring registers
	popl %edx
	popl %ecx

	testl %eax, %eax
	jz getline_main_loop_end

	cmpb $0xA, (%edx, %ecx)
	je getline_main_loop_end

	incl %ecx

	jmp getline_main_loop

getline_main_loop_end:
	movl $0x0, 1(%edx, %ecx)
	movl %ecx, %edx
	incl %edx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type lputc, @function
lputc:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	leal first_arg(%ebp), %eax
	movl second_arg(%ebp), %ebx

	# I/O flow
	pushl $0x1
	pushl %eax # &a
	pushl %ebx
	call write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

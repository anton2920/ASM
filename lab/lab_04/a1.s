.equ STDIN, 0
.equ STDOUT, 1

.equ sizeof_int, 4

.equ first_arg, sizeof_int + sizeof_int
.equ second_arg, first_arg + sizeof_int
.equ third_arg, second_arg + sizeof_int

.section .rodata
output1:
	.ascii "Type first string: \0"
	.equ len_output1, . - output1
output2:
	.ascii "Type second string: \0"
	.equ len_output2, . - output2
answer1:
	.ascii "\nFirst string is greater than second\n\0"
	.equ len_answer1, . - answer1
answer2:
	.ascii "\nSecond string is greater than first\n\0"
	.equ len_answer2, . - answer2
answer3:
	.ascii "\nThese strings are equal\n\0"
	.equ len_answer3, . - answer3


.section .bss
.equ BUFSIZE, 500
.lcomm buffer1, BUFSIZE
.lcomm buffer2, BUFSIZE

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# I/O flow
	pushl $len_output1
	pushl $output1
	pushl $STDOUT
	call write
	addl $0xC, %esp

	leal buffer1, %eax
	movl $BUFSIZE, %ebx
	call sread

	leal buffer1, %ebx
	movb $0x0, -1(%ebx, %eax)

	pushl $len_output2
	pushl $output2
	pushl $STDOUT
	call write
	addl $0xC, %esp

	leal buffer2, %eax
	movl $BUFSIZE, %ebx
	call sread

	leal buffer2, %ebx
	movb $0x0, -1(%ebx, %eax)

	pushl $buffer2
	pushl $buffer1
	call lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	js less_than
	jnz greater_than

	pushl $len_answer3
	pushl $answer3
	pushl $STDOUT
	call write
	addl $0xC, %esp

	jmp exit

less_than:
	pushl $len_answer2
	pushl $answer2
	pushl $STDOUT
	call write
	addl $0xC, %esp

	jmp exit
	
greater_than:
	pushl $len_answer1
	pushl $answer1
	pushl $STDOUT
	call write
	addl $0xC, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

# %eax - buffer, %ebx - nbytes
.type write, @function
.equ SYS_WRITE, 4
write:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Syscall
	movl $SYS_WRITE, %eax
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

.type sread, @function
.equ SYS_READ, 3
sread:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Syscall
	movl %eax, %ecx
	movl %ebx, %edx
	movl $SYS_READ, %eax
	movl $STDIN, %ebx
	int $0x80 # 0x80's interrupt

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type lstrlen, @function
.equ LSTRLEN_ERR, -1
lstrlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %edi

	# Initializing variables
	movl first_arg(%ebp), %edi
	xorl %eax, %eax
	movl $0xFFFF, %ecx

	# Main part
	cld
	repnz scasb
	jne not_found

	subw $0xFFFF, %cx
	negw %cx
	decw %cx

	# Returning value
	movl %ecx, %eax

	jmp lstrlen_exit

not_found:
	movl $LSTRLEN_ERR, %eax

lstrlen_exit:
	# Restoring registers
	popl %edi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type lstrcmp, @function
.equ LESS_THAN, -1
.equ EQUALS, 0
.equ GREATER_THAN, 1
lstrcmp:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %edi
	pushl %esi
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %esi
	movl second_arg(%ebp), %edi

	# Main part
	pushl %esi
	call lstrlen
	addl $0x4, %esp

	movl %eax, %ecx
	incl %ecx

	movl $EQUALS, %eax
	movl $LESS_THAN, %ebx
	movl $GREATER_THAN, %edx

	cld
	repz cmpsb

	# Returning value
	cmovll %ebx, %eax
	cmovgl %edx, %eax

	# Restoring registers
	popl %ebx
	popl %esi
	popl %edi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

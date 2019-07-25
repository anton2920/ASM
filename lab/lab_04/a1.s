.section .data
output1:
	.ascii "Type first string: \0"
	.equ len_output1, . - output1
output2:
	.ascii "Type second string: \0"
	.equ len_output2, . - output2
answer1:
	.ascii "First string is greater than second\n\0"
	.equ len_answer1, . - answer1
answer2:
	.ascii "Second string is greater than first\n\0"
	.equ len_answer2, . - answer2
answer3:
	.ascii "These strings are equal\n\0"
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
	call write
	addl $0x8, %esp

	pushl $BUFSIZE
	pushl $buffer1
	call read
	addl $0x8, %esp

	movl $buffer1, %ebx
	movb $0x0, (%ebx, %eax, 1)

	pushl $len_output2
	pushl $output2
	call write
	addl $0x8, %esp

	pushl $BUFSIZE
	pushl $buffer2
	call read
	addl $0x8, %esp

	movl $buffer2, %ebx
	movb $0x0, (%ebx, %eax, 1)

	# Main part
	pushl $buffer2
	pushl $buffer1
	call strcmp
	addl $0x8, %esp

	# Final output
	cmpl $0x0, %eax
	jg greater
	jl less

	pushl $len_answer3
	pushl $answer3
	call write
	addl $0x8, %esp

	jmp exit

greater: 
	pushl $len_answer1
	pushl $answer1
	call write
	addl $0x8, %esp

	jmp exit

less:
	pushl $len_answer2
	pushl $answer2
	call write
	addl $0x8, %esp

	# Exitting
exit:
	movl $0x1, %eax
	xorl %ebp, %ebp
	int $0x80 # 0x80's interrupt

.type write, @function
.equ SYS_WRITE, 4
.equ STDOUT, 1
write:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	movl $SYS_WRITE, %eax
	movl $STDOUT, %ebx
	movl 8(%ebp), %ecx
	movl 12(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type read, @function
.equ SYS_READ, 3
read:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	movl $SYS_READ, %eax
	xorl %ebx, %ebx
	movl 8(%ebp), %ecx
	movl 12(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type strcmp, @function
strcmp:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx

	# Main part
loop:
	xorl %ecx, %ecx
	xorl %edx, %edx

	movb (%eax), %cl
	movb (%ebx), %dl
	cmpb %cl, %dl
	jne end_loop

	cmpb $0x0, %cl
	jz end_loop

	incl %eax
	incl %ebx
	jmp loop
	
end_loop:
	subl %edx, %ecx
	movl %ecx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

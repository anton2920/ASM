.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ first_arg, 8
.equ second_arg, 12
.equ third_arg, 16

.section .text
.globl write
.type write, @function
.equ SYS_WRITE, 4
write:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Syscall
	movl $SYS_WRITE, %eax
	movl first_arg(%ebp), %ebx
	movl second_arg(%ebp), %ecx
	movl third_arg(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl read
.type read, @function
.equ SYS_READ, 3
read:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Syscall
	movl $SYS_READ, %eax
	movl first_arg(%ebp), %ebx
	movl second_arg(%ebp), %ecx
	movl third_arg(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl strlen
.type strlen, @function's
strlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl first_arg(%ebp), %esi
	xorl %eax, %eax
	cld
	movl $0xFFFF, %ecx

	# Main part
	repne scasb
	jne notfound

	subw $0xFFFF, %cx
	negw %cx
	decw %cx

	movl %ecx, %eax

	jmp strlen_fin

notfound:
	movl $-1, %eax

strlen_fin:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

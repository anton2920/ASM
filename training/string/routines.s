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

.globl lstrlen
.type lstrlen, @function
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
	jne notfound

	subw $0xFFFF, %cx
	negw %cx
	decw %cx

	movl %ecx, %eax

	jmp lstrlen_fin

notfound:
	movl $-1, %eax

lstrlen_fin:
	# Restoring registers
	popl %edi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl lstrcmp
.type lstrcmp, @function
.equ LESS_THAN, -1
.equ GREATER_THAN, 1
lstrcmp:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %esi
	pushl %edi
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

	movl $GREATER_THAN, %ebx
	movl $LESS_THAN, %edx
	xorl %eax, %eax

	cld
	repz cmpsb

	cmovgl %ebx, %eax
	cmovll %edx, %eax

	# Restoring registers
	popl %ebx
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl lstrcpy
.type lstrcpy, @function
lstrcpy:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %esi
	pushl %edi

	# Initializing variables
	movl first_arg(%ebp), %edi
	movl second_arg(%ebp), %esi

	# Main part
	pushl %esi
	call lstrlen
	addl $0x4, %esp

	movl %eax, %ecx
	sarl $0x2, %ecx
	cld
	rep movsl

	movl %eax, %ecx
	andl $0x3, %ecx
	rep movsb

	# Returning value
	movl %edi, %eax

	# Restoring registers
	popl %ebx
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.section .data

.section .bss 
.lcomm NUM_BUF, 500

.section .text
.globl write
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

.globl read
.type read, @function
.equ SYS_READ, 3
.equ STDIN, 0
read:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	movl $SYS_READ, %eax
	movl $STDIN, %ebx
	movl 8(%ebp), %ecx
	movl 12(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl strcmp
.type strcmp, @function
strcmp:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx

	# Main part
strcmp_loop:
	xorl %ecx, %ecx # c = 0
	xorl %edx, %edx # d = 0

	movb (%eax), %cl
	movb (%ebx), %dl
	cmpb %dl, %cl # if (*c != *d)
	jne strcmp_end_loop
	jz strcmp_end_loop

	incl %eax
	incl %ebx
	jmp strcmp_loop
	
strcmp_end_loop:
	subl %edx, %ecx # c -= d
	movl %ecx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl atoi
.type atoi, @function
atoi:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ sign, -4
	subl $0x4, %esp # Acquiring space in sign(%ebp) — minus sign
	movl $0x1, sign(%ebp)

	# Initializing variables
	.equ req_str, 8
	movl req_str(%ebp), %ebx
	xorl %ecx, %ecx # offset
	xorl %eax, %eax # res

	# Main part
atoi_if:
	xorl %edx, %edx
	movb (%ebx), %dl
	cmpb $'-', %dl # if (d == '-')
	jne atoi_if_2

atoi_then:
	movl $-1, sign(%ebp) # sign = 
	incl %ecx
	jmp atoi_main_loop

atoi_if_2:
	cmpb $'+', %dl # if (d == '+')
	jne atoi_main_loop

atoi_then_2:
	movl $0x1, sign(%ebp)
	incl %ecx

atoi_main_loop:
	xorl %edx, %edx
	movb (%ebx, %ecx, 1), %dl
	cmpb $0x0, %dl
	je atoi_main_loop_end

	subb $'0', %dl
	imull $0xA, %eax
	addl %edx, %eax

	incl %ecx

	jmp atoi_main_loop

atoi_main_loop_end:
	movl sign(%ebp), %edx
	imull %edx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret
	
.globl iprint
.type iprint, @function
iprint:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # Number

	# Main part
iprint_if:
	cmpl $0x0, %eax # if (a > 0)
	jg iprint_else

iprint_then:
	cmpl $0x0, %eax
	je iprint_print_0
	
	pushl %eax
	movl $'-', %edx
	pushl %edx
	call putchar
	addl $0x4, %esp
	popl %eax

	imull $-1, %eax

iprint_else:
	pushl %eax

	pushl %eax
	call numlen
	addl $0x4, %esp

	popl %ebx
	pushl %eax

	pushl %eax
	pushl %ebx
	call reverse
	addl $0x8, %esp

	popl %eax
	imull $0x4, %eax
	pushl %eax
	pushl $NUM_BUF
	call write
	addl $0x8, %esp
	jmp iprint_fin

iprint_print_0:
	movl $'0', %edx
	pushl %edx
	call putchar
	addl $0x4, %esp

iprint_fin:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type reverse, @function # int and char *
reverse:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # Number
	movl 12(%ebp), %ebx # Position
	decl %ebx
	movl $0xA, %ecx
	movl $NUM_BUF, %edi

	# Main part
reverse_main_loop:
	cmpl $0x0, %ebx
	jl reverse_main_loop_end

	xorl %edx, %edx
	idivl %ecx

	addl $'0', %edx
	movl %edx, (%edi, %ebx, 4)
	decl %ebx

	jmp reverse_main_loop

reverse_main_loop_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type putchar, @function
putchar:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	leal 8(%ebp), %eax
	movl $0x1, %ebx

	pushl %ebx 
	pushl %eax # &a
	call write
	addl $0x8, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type numlen, @function
numlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	movl 8(%ebp), %eax # Number
	xorl %ebx, %ebx # Len
	movl $0xA, %ecx

numlen_loop:
	cmpl $0x0, %eax
	je numlen_loop_end

	xorl %edx, %edx
	idivl %ecx

	incl %ebx

	jmp numlen_loop

numlen_loop_end:
	movl %ebx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

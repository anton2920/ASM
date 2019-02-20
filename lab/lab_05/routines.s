.section .data
space:
	.ascii " \0"
	.equ len_space, . - space

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

.globl swap
.type swap, @function
swap:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	.equ a, 8
	.equ b, 12
	movl a(%ebp), %eax # &a
	movl b(%ebp), %ebx # &b
	movl (%eax), %ecx # c = *a
	movl (%ebx), %edx # d = *b

	movl %ecx, %esi # s = *a
	movl %edx, (%eax) # *a = *b
	movl %esi, (%ebx) # *b = *a

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

	# Main part
	.equ req_str, 8
	movl req_str(%ebp), %ebx
	xorl %ecx, %ecx
	xorl %eax, %eax # res

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

	# Main part
	movl 8(%ebp), %eax # Number

	pushl %eax
	call reverse
	addl $0x4, %esp

iprint_loop:
	movl $0xA, %ebx
	xorl %edx, %edx
	idivl %ebx

	# Saving registers
	pushl %eax

	addl $'0', %edx
	pushl %edx
	call putchar
	addl $0x4, %esp

	# Restoring registers
	popl %eax

	cmpl $0x0, %eax
	je iprint_loop_end

	jmp iprint_loop

iprint_loop_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type reverse, @function
reverse:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	movl 8(%ebp), %eax # Number
	xorl %ebx, %ebx
	movl $0xA, %ecx

reverse_main_loop:
	cmpl $0x0, %eax
	je reverse_main_loop_end

	xorl %edx, %edx
	idivl %ecx

	imull %ecx, %ebx
	addl %edx, %ebx

	jmp reverse_main_loop

reverse_main_loop_end:
	movl %ebx, %eax

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

.globl print_arr
.type print_arr, @function
print_arr:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	xorl %ecx, %ecx

print_arr_loop:
	cmpl %ecx, %ebx # if (b == c)
	je print_arr_loop_end

	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx

	movl (%eax, %ecx, 4), %edx
	pushl %edx
	call atoi
	addl $0x4, %esp

	pushl %eax
	call iprint
	addl $0x4, %esp

	pushl $len_space
	pushl $space
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %ecx
	popl %ebx
	popl %eax

	incl %ecx

	jmp print_arr_loop

print_arr_loop_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

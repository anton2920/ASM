.section .data
space:
	.ascii " \0"
	.equ len_space, . - space

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

.globl print_arr
.type print_arr, @function
print_arr:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx
	xorl %ecx, %ecx

	# Main part
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

.globl print_arr_buf
.type print_arr_buf, @function
print_arr_buf:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %ebx # Number of elements
	movl 12(%ebp), %eax # Buffer
	xorl %ecx, %ecx

	# Main part
print_arr_buf_loop:
	cmpl %ecx, %ebx
	je print_arr_buf_loop_end

	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx

	movl (%eax, %ecx, 4), %edx
	pushl %edx
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

	jmp print_arr_buf_loop

print_arr_buf_loop_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

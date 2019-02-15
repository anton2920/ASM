.section .data
sum:
	.ascii "Sum of the elements equals to \0"
	.equ len_sum, . - sum
sorted_array:
	.ascii "Sorted array: \0"
	.equ len_sorted_array, . - sorted_array
even_numbers:
	.ascii "Even numbers: \0"
	.equ len_even_numbers, . - even_numbers
newline:
	.ascii "\n\0"
	.equ len_newline, . - newline
error_line:
	.ascii "Error! No elements found!\n\0"
	.equ len_error_line, . - error_line

.section .bss
.equ BUFSIZE, 500
.lcomm BUF, BUFSIZE

.section .text
.globl _start
_start:
	
	# Initializing stack frame
	movl %esp, %ebp

	# Main part
	.equ ARGC, 0
	.equ ARGV_1, 8

	movl ARGC(%ebp), %ecx
	decl %ecx
	movl ARGV_1(%ebp), %eax

	cmpl $0x1, %ecx
	jle error

	pushl %ecx
	pushl %eax
	call sum_of_elem
	addl $0x8, %esp

error:
	pushl $len_error_line
	pushl $error_line
	call write
	addl $0x8, %esp

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type sum_of_elem, @function
sum_of_elem:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	xorl %ecx, %ecx
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx # b = argc
	xorl %edx, %edx # sum

sum_loop:
	cmpl %ecx, %ebx
	je sum_loop_exit

	addl (%eax, %ecx, 4), %edx
	incl %ecx

	jmp sum_loop

sum_loop_exit:
	movl %edx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

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

.type bubble_sort, @function
bubble_sort:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ var, -4
	.equ edx_val, -8
	subl $0x4, %esp # Acquiring space in -4(%ebp) — flag

	# Main part
	movl 8(%ebp), %eax # array
	movl 12(%ebp), %ebx # num_of_elem

	pushl %ebx
	pushl %eax
	movl %ebx, %eax
	xorl %edx, %edx
	movl $0x2, %ebx
	idivl %ebx

	movl %eax, %ecx
	popl %eax
	popl %ebx

	xorl %esi, %esi
	movl $0x1, %edi


outer_loop:
	cmpl %ecx, %esi
	je outer_loop_end

	cmpl $0x0, var(%ebp)
	je outer_loop_end

	movl $0x0, var(%ebp)

inner_loop:
	cmpl %ebx, %edi
	je inner_loop_end

	pushl -4(%eax, %edi, 4)
	movl (%eax, %edi, 4), %edx
if:
	cmpl edx_val(%ebp), %edx
	jle else

then:
	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %esi
	pushl %edi

	pushl %edx
	pushl edx_val(%ebp)
	call swap
	addl $0x8, %esp

	# Restoring registers
	popl %edi
	popl %esi
	popl %ecx
	popl %ebx
	popl %eax

	movl $0x1, var(%ebp)

else:
	incl %edi
	jmp inner_loop

inner_loop_end:
	incl %esi
	decl %ebx
	jmp outer_loop

outer_loop_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type swap, @function
swap:
	# Initializing fucntion's stack frame
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

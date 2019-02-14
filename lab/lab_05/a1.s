.section .data
format_number:
	.ascii "%d\0"
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

	cmpl $0x1, %cx
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
	movl 12(%ebp), %ebx # b = argc
loop:
	cmpl 


.type write, @function
.equ SYS_WRITE, 4
.equ STDOUT, 1
write:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	movl $SYS_WRITE, %eax
	movl $STDOUT
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

	# Main part
	xorl %esi, %esi
	xorl %edi, %edi

	
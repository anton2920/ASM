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
	leal ARGV_1(%ebp), %eax

	cmpl $0x0, %ecx
	jle error

sum_elem:
	# Sum of elements

	# Saving registers
	pushl %eax
	pushl %ecx

	pushl $len_sum
	pushl $sum
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %ecx
	popl %eax

	# Saving registers
	pushl %eax
	pushl %ecx

	pushl %ecx
	pushl %eax
	call sum_of_elem
	addl $0x8, %esp

	pushl %eax
	call iprint
	addl $0x4, %esp

	pushl $len_newline
	pushl $newline
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %ecx
	popl %eax

sorting:
	# Sort

	# Saving registers
	pushl %eax
	pushl %ecx

	pushl $len_sorted_array
	pushl $sorted_array
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %ecx
	popl %eax

	# Saving registers
	pushl %eax
	pushl %ecx

	pushl %ecx
	pushl %eax
	call bubble_sort
	addl $0x8, %esp

	# Restoring registers
	popl %ecx
	popl %eax

	# Saving registers
	pushl %eax
	pushl %ecx

	pushl %ecx
	pushl %eax
	call print_arr
	addl $0x8, %esp

	pushl $len_newline
	pushl $newline
	call write
	addl $0x8, %esp

	# Restoring registers
	popl %ecx
	popl %eax

	jmp exit

error:
	pushl $len_error_line
	pushl $error_line
	call write
	addl $0x8, %esp

exit:
	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.globl sum_of_elem
.type sum_of_elem, @function
sum_of_elem:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ d, -4
	subl $0x4, %esp # Acquiring space in -4(%ebp)

	# Main part
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx # b = argc
	decl %ebx
	movl $0x0, d(%ebp) # sum

sum_loop:
	cmpl $0x0, %ebx
	jl sum_loop_exit

	# Saving registers
	pushl %eax
	pushl %ebx
	
	movl (%eax, %ebx, 4), %edx
	pushl %edx
	call atoi
	addl $0x4, %esp

	popl %ebx
	addl %eax, d(%ebp)
	decl %ebx

	popl %eax

	jmp sum_loop

sum_loop_exit:
	movl d(%ebp), %eax # Result

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl bubble_sort
.type bubble_sort, @function
bubble_sort:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ flag, -4
	.equ edx_val, -8
	subl $0x8, %esp # Acquiring space for two variables

	# Main part
	movl 8(%ebp), %eax # array
	movl 12(%ebp), %ebx # num_of_elem
		
	movl %ebx, %ecx
	xorl %esi, %esi

outer_loop:
	cmpl %esi, %ecx # if (c < s)
	jl outer_loop_end

	cmpl $0x0, flag(%ebp)
	je outer_loop_end

	movl $0x0, flag(%ebp)

	movl $0x1, %edi
inner_loop:
	cmpl %ebx, %edi
	je inner_loop_end

	# NumCmp

	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx

	movl -4(%eax, %edi, 4), %edx
	pushl %edx
	call atoi
	addl $0x4, %esp
	movl %eax, edx_val(%ebp) # First number

	# Restoring registers
	popl %ecx
	popl %ebx
	popl %eax

	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx

	movl (%eax, %edi, 4), %edx
	pushl %edx
	call atoi
	addl $0x4, %esp
	movl %eax, %edx # Second number

	# Restoring registers
	popl %ecx
	popl %ebx
	popl %eax

if:
	cmpl edx_val(%ebp), %edx # if (*d <= *(d - 4))
	jg else

then:
	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %esi
	pushl %edi

	leal (%eax, %edi, 4), %edx
	pushl %edx
	leal -4(%eax, %edi, 4), %edx
	pushl %edx
	call swap
	addl $0x8, %esp

	# Restoring registers
	popl %edi
	popl %esi
	popl %ecx
	popl %ebx
	popl %eax

	movl $0x1, flag(%ebp)

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

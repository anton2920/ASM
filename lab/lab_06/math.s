.globl summirovaniye
.type summirovaniye, @function
summirovaniye:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # a
	movl 12(%ebp), %ebx # b

	# Main part
	addl %ebx, %eax # a = a + b

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl vichitaniye
.type vichitaniye, @function
vichitaniye:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # a
	movl 12(%ebp), %ebx # b

	# Main part
	subl %ebx, %eax # a = a - b

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl umnogeniye
.type umnogeniye, @function
umnogeniye:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # a
	movl 12(%ebp), %ebx # b

	# Main part
	imull %ebx, %eax # a = a * b

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl deleniye
.type deleniye, @function
deleniye:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %esi # s = &a
	movl 12(%ebp), %ebx # b
	xorl %edx, %edx

	# Main part
	cmpl $0x0, %ebx
	je deleniye_wrong

	movl (%esi), %eax
	idivl (%ebx)
	movl %edx, (%ebx)

	jmp deleniye_exit

deleniye_wrong:
	movl $-1, %eax

deleniye_exit:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl power
.type power, @function
power:
	# Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp # Acquiring space in -4(%ebp)

    # Initializing variables
    movl 8(%ebp), %ebx # base
    movl 12(%ebp), %ecx # power

    # Main part
    movl $0x1, -4(%ebp) # current = 1
    cmpl $0x0, %ecx # if (power == 0)
    je end_lpow

    movl %ebx, -4(%ebp) # current = %ebx = base

pow_start_loop:
    cmpl $0x1, %ecx
    je end_lpow

    movl -4(%ebp), %eax
    imul %ebx, %eax
    movl %eax, -4(%ebp)
    decl %ecx
    jmp pow_start_loop

end_lpow:
	# Destroying function's stack frame
    movl -4(%ebp), %eax
    movl %ebp, %esp
    popl %ebp
    ret

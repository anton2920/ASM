.section .data
format_input:
	.ascii "%d\0"
format_output1:
	.ascii "Type a: \0"
format_output2:
	.ascii "Type b: \0"
format_output3:
	.ascii "Type c: \0"
format_answer:
	.ascii "%c: Sum of digits = %d, Product of diigits = %d\n\0"

.section .text
.globl _start
_start:
	
	# Initializing stack frame
	movl %esp, %ebp
	.equ var, -4
	subl $0xC, %esp # Acquiring space for three variables

	# Initializing variables
	.equ sum, -8
	.equ prod, -12
	movl $0x0, sum(%ebp)
	movl $0x1, prod(%ebp)

	# I/O flow
	pushl $format_output1
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax

	pushl $format_output2
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax

	pushl $format_output3
	call printf
	addl $0x4, %esp

	leal var(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp
	movl var(%ebp), %eax
	pushl %eax

	# Main part
	leal sum(%ebp), %ebx # b = &sum
	leal prod(%ebp), %ecx # c = &prod

	pushl -16(%ebp)
	pushl %ecx
	pushl %ebx
	call dig_sum_mul
	addl $0xC, %esp

	# printf
	pushl prod(%ebp)
	pushl sum(%ebp)
	movb $'a', %al
	pushl %eax
	pushl $format_answer
	call printf
	addl $0xC, %esp

	movl $0x0, sum(%ebp)
	movl $0x1, prod(%ebp)
	leal sum(%ebp), %ebx # b = &sum
	leal prod(%ebp), %ecx # c = &prod

	pushl -20(%ebp)
	pushl %ecx
	pushl %ebx
	call dig_sum_mul
	addl $0xC, %esp

	# printf
	pushl prod(%ebp)
	pushl sum(%ebp)
	movb $'b', %al
	pushl %eax
	pushl $format_answer
	call printf
	addl $0xC, %esp

	movl $0x0, sum(%ebp)
	movl $0x1, prod(%ebp)
	leal sum(%ebp), %ebx # b = &sum
	leal prod(%ebp), %ecx # c = &prod

	pushl -24(%ebp)
	pushl %ecx
	pushl %ebx
	call dig_sum_mul
	addl $0xC, %esp

	# printf
	pushl prod(%ebp)
	pushl sum(%ebp)
	movb $'c', %al
	pushl %eax
	pushl $format_answer
	call printf
	addl $0xC, %esp

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type dig_sum_mul, @function
dig_sum_mul:
	
	# Initializing funnnction's stack frame
	pushl %ebp
	movl %esp, %ebp
	# subl $0x4, %esp # Acquiring space for three variables

	# Initializing variables
	movl 16(%ebp), %eax # num

	xorl %edi, %edi # sum
	movl $0x1, %esi # prod
	movl $0xA, %ebx # b = 10

	# Main part
loop_begin:
	cmpl $0x0, %eax
	je loop_end

	xorl %edx, %edx
	idivl %ebx # num / 10

	addl %edx, %edi # sum += (num % 10)
	imull %edx, %esi # prod *= (num % 10)

	jmp loop_begin

loop_end:
	movl 8(%ebp), %eax # sum
	movl %edi, (%eax) # *(sum) = sum
	movl 12(%ebp), %eax # prod
	movl %esi, (%eax) # *(prod) = prod

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

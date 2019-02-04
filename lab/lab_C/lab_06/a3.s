.section .data
format_input:
	.ascii "%d\0"
format_output1:
	.ascii "Type day: \0"
format_output2:
	.ascii "Type month: \0"
format_answer:
	.ascii "Answer: %d.%d\n\0"
format_error:
	.ascii "Error! Wrong date!\n\0"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ var, -4
	subl $var, %esp # Acquiring space in var(%ebp)

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

	# Main part
	popl %ebx # month
	popl %eax # day

check_day:
	cmpl $32, %eax # if (day >= 32)
	jge print_err

switch2:
	cmpl $0x2, %ebx
	je sw2_cs2

	cmpl $0x4, %ebx
	je sw2_cs4

	cmpl $0x6, %ebx
	je sw2_cs6

	cmpl $0x9, %ebx
	je sw2_cs9

	cmpl $0xB, %ebx
	je sw2_csB

	jmp main_part

sw2_cs2:
	cmpl $29, %eax
	jge print_err

sw2_cs4:
sw2_cs6:
sw2_cs9:
sw2_csB:
	cmpl $31, %eax
	jge print_err

main_part:
	decl %eax # --day
	cmpl $0x0, %eax # if (day <= 0)
	jle decl_month
	jmp end_decl

decl_month:
	decl %ebx # --month
	cmpl $0x0, %ebx # if (month == 0)
	je make_december

switch1:
	cmpl $0x1, %ebx
	je sw1_cs1

	cmpl $0x2, %ebx
	je sw1_cs2

	cmpl $0x3, %ebx
	je sw1_cs3

	cmpl $0x4, %ebx
	je sw1_cs4

	cmpl $0x5, %ebx
	je sw1_cs5

	cmpl $0x6, %ebx
	je sw1_cs6

	cmpl $0x7, %ebx
	je sw1_cs7

	cmpl $0x8, %ebx
	je sw1_cs8

	cmpl $0x9, %ebx
	je sw1_cs9

	cmpl $0xA, %ebx
	je sw1_csA

	cmpl $0xB, %ebx
	je sw1_csB

	cmpl $0xC, %ebx
	je sw1_csC

sw1_cs1:
sw1_cs3:	
sw1_cs5:
sw1_cs7:
sw1_cs8:
sw1_csA:
sw1_csC:
	movl $31, %eax # day = 31
	jmp end_decl

sw1_cs2:
	movl $28, %eax # day = 28
	jmp end_decl

sw1_cs4:
sw1_cs6:
sw1_cs9:
sw1_csB:
	movl $30, %eax
	jmp end_decl
	
make_december:
	movl $0xC, %ebx
	movl $31, %eax
	jmp end_decl

end_decl:
	# Final output
	pushl %ebx
	pushl %eax
	pushl $format_answer
	call printf
	addl $0x10, %esp
	jmp exit

print_err:
	pushl $format_error
	call printf
	addl $0x4, %esp

exit:
	# Exiting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

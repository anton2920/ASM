.section .rodata
format_input:
	.asciz "%d"
format_output_1:
	.asciz "Type value: "
format_output_2:
	.asciz "Type suit: "
format_answer:
	.asciz "Answer: %s of %s\n"
format_error_1:
	.asciz "Error! Wrong suit!\n"
format_error_2:
	.asciz "Error! Wrong value!\n"
format_six:
	.asciz "Six"
format_seven:
	.asciz "Seven"
format_eight:
	.asciz "Eight"
format_nine:
	.asciz "Nine"
format_ten:
	.asciz "Ten"
format_jack:
	.asciz "Jack"
format_queen:
	.asciz "Queen"
format_king:
	.asciz "King"
format_ace:
	.asciz "Ace"
format_spades:
	.asciz "spades"
format_diamonds:
	.asciz "diamonds"
format_clubs:
	.asciz "clubs"
format_hearts:
	.asciz "hearts"

.section .bss

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x8, %esp # Acquiring space for two variables
	.equ VAR_A, -4
	.equ VAR_B, -8
 
	# I/O flow
	pushl $format_output_1
	call printf
	addl $0x4, %esp

	leal VAR_A(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	pushl $format_output_2
	call printf
	addl $0x4, %esp

	leal VAR_B(%ebp), %eax
	pushl %eax
	pushl $format_input
	call scanf
	addl $0x8, %esp

	# Main part
	movl VAR_B(%ebp), %eax

switch_case:
	cmpl $0x1, %eax
	je case_spades

	cmpl $0x2, %eax
	je case_clubs

	cmpl $0x3, %eax
	je case_diamonds

	cmpl $0x4, %eax
	je case_hearts

	jmp case_default

case_spades:
	pushl $format_spades
	jmp switch_end

case_clubs:
	pushl $format_clubs
	jmp switch_end

case_diamonds:
	pushl $format_diamonds
	jmp switch_end	

case_hearts:
	pushl $format_hearts
	jmp switch_end

case_default:
	pushl $format_error_1
	call printf
	addl $0x4, %esp
	jmp exit

switch_end:
	movl VAR_A(%ebp), %eax

switch2_case:
	cmpl $0x6, %eax
	je case2_6

	cmpl $0x7, %eax
	je case2_7

	cmpl $0x8, %eax
	je case2_8

	cmpl $0x9, %eax
	je case2_9

	cmpl $0xA, %eax
	je case2_10

	cmpl $0xB, %eax
	je case2_J

	cmpl $0xC, %eax
	je case2_Q

	cmpl $0xD, %eax
	je case2_K

	cmpl $0xE, %eax
	je case2_A

	jmp case2_default

case2_6:
	pushl $format_six
	jmp switch2_end

case2_7:
	pushl $format_seven
	jmp switch2_end

case2_8:
	pushl $format_eight
	jmp switch2_end

case2_9:
	pushl $format_nine
	jmp switch2_end

case2_10:
	pushl $format_ten
	jmp switch2_end

case2_J:
	pushl $format_jack
	jmp switch2_end

case2_Q:
	pushl $format_queen
	jmp switch2_end

case2_K:
	pushl $format_king
	jmp switch2_end

case2_A:
	pushl $format_ace
	jmp switch2_end

case2_default:
	addl $0x4, %esp
	push $format_error_2
	call printf
	addl $0x4, %esp
	jmp exit

switch2_end:
	pushl $format_answer
	call printf
	addl $0x8, %esp

exit:
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

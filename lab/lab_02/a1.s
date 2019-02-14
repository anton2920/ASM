.section .data
msg:
	.ascii "Hello, GAS, GNU Assembler!\n\0"
	.equ len, . - msg # Length of msg
msg2:
	.ascii "Test string\n\0"
	.equ len2, . - msg2 # Length of msg2

.section .text
.globl _start
_start:

	# Initializing stack frame
	movl %esp, %ebp

	# Main part
#	movl $msg, %ebx # Saving pointer to beginning of the string 
#	movl %ebx, %eax

#nextchar:
#	cmpb $0x0, (%eax) # Comparing '\0' with beginning of the string
#	jz finished # If true, go to «finished» label, ending loop

#	incl %eax # Increasing %eax by 1
#	jmp nextchar

#finished:
#	subl %ebx, %eax # Subtracting %ebx from %eax; result — length of the string

	# First string
	movl $len, %edx # Outputing the string
	movl $msg, %ecx
	movl $0x4, %eax
	movl $0x1, %ebx
	int $0x80 # 0x80's interrupt

	# Second string
	movl $0x4, %eax
	movl $0x1, %ebx
	movl $msg2, %ecx
	movl $len2, %edx
	int $0x80 # 0x80's interrupt

	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

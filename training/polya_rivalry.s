.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.section .data
initial_text:
	.asciz "Type the text: "
	.equ len_initial_text, . - initial_text
text_cont:
	.asciz "This text contains following uppercase vowels: "
	.equ len_text_cont, . - text_cont
special_set:
	.asciz " "
	.equ len_special_set, . - special_set
newline:
	.asciz "\n"
	.equ len_newline, . - newline
n:
	.long 0
bufp:
	.long 0
flag:
	.byte 0

.section .bss
.equ BUFSIZE, 500
.lcomm buffer, BUFSIZE

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x6, %esp
	movb $0x0, (%ebp)
	movb $0x0, -1(%ebp)
	movb $0x0, -2(%ebp)
	movb $0x0, -3(%ebp)
	movb $0x0, -4(%ebp)
	movb $0x0, -5(%ebp)

	# I/O flow
	pushl $len_initial_text
	pushl $initial_text
	pushl $STDOUT
	call write
	addl $0xC, %esp

while_not_n:
	call getchar

	xorl %edx, %edx
	movb %al, %dl

	cmpb $0xA, %dl
	je while_end

case_letter:
	cmpb $'A', %dl
	je got_a

	cmpb $'E', %dl
	je got_e

	cmpb $'I', %dl
	je got_i

	cmpb $'O', %dl
	je got_o

	cmpb $'U', %dl
	je got_u

	cmpb $'Y', %dl
	je got_y

	jmp while_not_n

got_a:
	movb $0x1, (%ebp)
	movb $0x1, flag
	jmp while_not_n

got_e:
	movb $0x1, -1(%ebp)
	movb $0x1, flag
	jmp while_not_n

got_i:
	movb $0x1, -2(%ebp)
	movb $0x1, flag
	jmp while_not_n

got_o:
	movb $0x1, -3(%ebp)
	movb $0x1, flag
	jmp while_not_n

got_u:
	movb $0x1, -4(%ebp)
	movb $0x1, flag
	jmp while_not_n

got_y:
	movl $0x1, -5(%ebp)
	movb $0x1, flag
	jmp while_not_n


while_end:
	cmpb $0x0, flag
	je exit_2

	pushl $0x10
	call putchar
	addl $0x4, %esp

answer:
	pushl $len_text_cont
	pushl $text_cont
	pushl $STDOUT
	call write

	addl $0xC, %esp

if_a:
	movb (%ebp), %al
	cmpb $0x1, %al
	jne if_e

	pushl $'A'
	call putchar
	addl $0x4, %esp
	call print_comma_and_space

if_e:
	movb -1(%ebp), %al
	cmpb $0x1, %al
	jne if_i

	pushl $'E'
	call putchar
	addl $0x4, %esp
	call print_comma_and_space

if_i:
	movb -2(%ebp), %al
	cmpb $0x1, %al
	jne if_o

	pushl $'I'
	call putchar
	addl $0x4, %esp
	call print_comma_and_space

if_o:
	movb -3(%ebp), %al
	cmpb $0x1, %al
	jne if_u

	pushl $'O'
	call putchar
	addl $0x4, %esp
	call print_comma_and_space

if_u:
	movb -4(%ebp), %al
	cmpb $0x1, %al
	jne if_y

	pushl $'U'
	call putchar
	addl $0x4, %esp
	call print_comma_and_space

if_y:
	movb -5(%ebp), %al
	cmpb $0x1, %al
	jne exit

	push $'Y'
	call putchar
	addl $0x4, %esp

exit:
	pushl $'\n'
	call putchar
	addl $0x4, %esp

exit_2:
	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

getchar:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	cmpl $0x0, n
	jne return_get

new_read:
	pushl $BUFSIZE
	pushl $buffer
	pushl $STDIN
	call read

	addl $0xC, %esp
	movl %eax, n
	movl $buffer, bufp

return_get:
	decl n
	cmpl $0x0, n
	jl return_get_2

	movl bufp, %ebx
	movl (%ebx), %eax
	incb bufp
	
	jmp return_get_end

return_get_2:
	movl $-1, %eax

return_get_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret


write:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl $SYS_WRITE, %eax # write syscall
	movl 8(%ebp), %ebx # fd
	movl 12(%ebp), %ecx # buffer
	movl 16(%ebp), %edx # BUFSIZE

	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

read:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl $SYS_READ, %eax # read syscall
	movl 8(%ebp), %ebx # fd
	movl 12(%ebp), %ecx # buffer
	movl 16(%ebp), %edx # BUFSIZE

	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

putchar: 
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	pushl $0x1
	leal 8(%ebp), %eax
	pushl %eax
	pushl $STDOUT
	call write

	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

print_comma_and_space:
	# Initializing variables
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	pushl $len_special_set
	pushl $special_set
	push $STDOUT
	call write

	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

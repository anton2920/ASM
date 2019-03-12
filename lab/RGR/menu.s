.section .data
quit_line:
	.ascii "quit\n\0"
one_line:
	.ascii "1\n\0"
two_line:
	.ascii "2\n\0"
line:
	.ascii " ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––\n\0"
	.equ len_line, . - line
no_cmd:
	.ascii "| menu: no such command!                                     |\n\0"
	.equ len_no_cmd, . - no_cmd
menu_line:
	.ascii " –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– \n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|                       >> Database <<                       |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|  >> Choose one of the following oprions:                   |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|       1) Create new database                               |\n\0"
	.ascii "|       2) Open existing database                            |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|       >> Type \"quit\" to terminate this program <<          |\n\0"
	.ascii "|                                                            |\n\0"

	.equ len_menu_line, . - menu_line
answer:
	.ascii "| Answer: \0"
	.equ len_answer, . - answer

.section .bss
.equ MENUBUF_LEN, 500
.lcomm MENUBUF, MENUBUF_LEN

.section .text
.type prt_ln, @function
prt_ln:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	pushl $len_line
	pushl $line
	call write
	addl $0x8, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl menu
.type menu, @function
menu:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

menu_loop:
	# I/O flow
	pushl $len_menu_line
	pushl $menu_line
	call write
	addl $0x8, %esp

	pushl $len_answer
	pushl $answer
	call write
	addl $0x8, %esp

	pushl $MENUBUF_LEN
	pushl $MENUBUF
	call read
	addl $0x8, %esp

	# Main part
	movl $MENUBUF, %ebx
	movb $0x0, (%ebx, %eax, 1)

	cmpl $0x5, %eax
	je check_quit

	cmpl $0x2, %eax
	je check_num

	jmp menu_error

check_quit:
	pushl $quit_line
	pushl $MENUBUF
	call strcmp
	addl $0x8, %esp

	cmpl $0x0, %eax
	je yes_quit

check_num:
	pushl $one_line
	pushl $MENUBUF
	call strcmp
	addl $0x8, %esp

	cmpl $0x0, %eax
	je yes_one

	pushl $two_line
	pushl $MENUBUF
	call strcmp
	addl $0x8, %esp

	cmpl $0x0, %eax
	je yes_two

menu_error:
	call prt_ln

	pushl $len_no_cmd
	pushl $no_cmd
	call write
	addl $0x8, %esp

	jmp menu_loop

yes_quit:
	xorl %eax, %eax
	jmp menu_end

yes_one:
	movl $0x1, %eax
	jmp menu_end

yes_two:
	movl $0x2, %eax
	jmp menu_end

menu_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp

	# Returning
	ret

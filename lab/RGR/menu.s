.include "constants.s"

.section .rodata
quit_line:
	.asciz "quit"
back_line:
	.asciz "back"
line:
	.ascii " ––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––\n\0"
	.equ len_line, . - line
no_cmd:
	.ascii "| menu: no such command                                      |\n\0"
	.equ len_no_cmd, . - no_cmd
menu_line:
	.ascii " –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– \n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|                       >> Database <<                       |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|  >> Choose one of the following options:                   |\n\0"
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

menu2_line:
	.ascii " –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– \n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|                       >> Database <<                       |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|  >> Choose one of the following options:                   |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|       1) Show existing records                             |\n\0"
	.ascii "|       2) Add new record                                    |\n\0"
	.ascii "|       3) Delete existing record                            |\n\0"
	.ascii "|       4) Edit existing record                              |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|       >> Type \"back\" to go to the previous menu <<         |\n\0"
	.ascii "|       >> Type \"quit\" to terminate this program <<          |\n\0"
	.ascii "|                                                            |\n\0"

	.equ len_menu2_line, . - menu2_line
quit_sure:
	.ascii "| Are you sure you want to exit? [Y/n]: \0"
	.equ len_quit_sure, . - quit_sure
quit_err:
	.ascii "| menu: type \"y\" or \"n\"                                      |\n\0"
	.equ len_quit_err, . - quit_err
back_sure:
	.asciz "| Are you sure you want to close this database? [Y/n]: "
	.equ len_back_sure, . - back_sure

.section .bss
.equ MENUBUF_LEN, 500
.lcomm MENUBUF, MENUBUF_LEN

.section .text
.globl prt_ln
.type prt_ln, @function
prt_ln:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	pushl $len_line
	pushl $line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl quit
.type quit, @function
quit:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

sure_quit:
	# Initializing variables
	movl first_arg(%ebp), %eax
	movl second_arg(%ebp), %ebx

	# I/O flow
	pushl %ebx
	pushl %eax
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $MENUBUF_LEN
	pushl $MENUBUF
	pushl $0x0
	call read
	addl $0xC, %esp
	
	movl $MENUBUF, %ebx

	xorl %ecx, %ecx
	movb (%ebx), %cl

	cmpl $0x1, %eax
	je test_nl

	cmpl $0x2, %eax
	je test_yn

test_nl:
	cmpb $'\n', %cl
	je ret_yes

	jmp ret_nocmd

test_yn:
	cmpb $'y', %cl
	je ret_yes

	cmpb $'Y', %cl
	je ret_yes

	cmpb $'n', %cl
	je ret_no

	cmpb $'N', %cl
	je ret_no

	jmp ret_nocmd

ret_yes:
	movl $0x1, %eax
	jmp quit_exit

ret_no:
	xorl %eax, %eax
	jmp quit_exit

ret_nocmd:
	call prt_ln

	pushl $len_quit_err
	pushl $quit_err
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp sure_quit

quit_exit:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl menu
.type menu, @function
menu:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

menu_loop:
	# I/O flow
	pushl $len_menu_line
	pushl $menu_line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $len_answer
	pushl $answer
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $MENUBUF_LEN
	pushl $MENUBUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	# Saving registers
	pushl %eax

	call prt_ln

	# Restoring registers
	popl %eax

	# Main part
	movl $MENUBUF, %ebx
	movb $0x0, -1(%ebx, %eax)

	cmpl $0x5, %eax
	je check_quit

	cmpl $0x2, %eax
	je check_num

	jmp menu_error

check_quit:
	pushl $quit_line
	pushl $MENUBUF
	call lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jz call_quit

check_num:
	cmpb $'1', (%ebx)
	je yes_one

	cmpb $'2', (%ebx)
	je yes_two

menu_error:
	pushl $len_no_cmd
	pushl $no_cmd
	pushl $STDOUT
	call write
	addl $0xC, %esp

	jmp menu_loop

call_quit:
	pushl $len_quit_sure
	pushl $quit_sure
	call quit
	addl $0x8, %esp

	testl %eax, %eax
	jz menu_loop

	call prt_ln

yes_quit:
	xorl %eax, %eax
	jmp menu_end

yes_one:
	movl $0x1, %eax
	jmp menu_end

yes_two:
	movl $0x2, %eax

menu_end:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl menu2
.type menu2, @function
menu2:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

menu2_loop:
	# I/O flow
	pushl $len_menu2_line
	pushl $menu2_line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $len_answer
	pushl $answer
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $MENUBUF_LEN
	pushl $MENUBUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	# Saving registers
	pushl %eax

	call prt_ln

	# Restoring registers
	popl %eax

	# Main part
	movl $MENUBUF, %ebx
	movb $0x0, -1(%ebx, %eax)

	cmpl $0x5, %eax
	je menu2_check_quit

	cmpl $0x2, %eax
	je menu2_check_num

	jmp menu2_error

menu2_check_quit:
	pushl $quit_line
	pushl $MENUBUF
	call lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jz menu2_call_quit

	pushl $back_line
	pushl $MENUBUF
	call lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jz menu2_call_back

	jmp menu2_error

menu2_check_num:
	cmpb $'1', (%ebx)
	je menu2_yes_one

	cmpl $'2', (%ebx)
	je menu2_yes_two

	cmpb $'3', (%ebx)
	je menu2_yes_three

	cmpb $'4', (%ebx)
	je menu2_yes_four

menu2_error:
	pushl $len_no_cmd
	pushl $no_cmd
	pushl $STDOUT
	call write
	addl $0xC, %esp

	jmp menu2_loop

menu2_call_quit:
	pushl $len_quit_sure
	pushl $quit_sure
	call quit
	addl $0x8, %esp

	testl %eax, %eax
	jz menu2_loop

	call prt_ln

menu2_yes_quit:
	xorl %eax, %eax
	jmp menu2_end

menu2_call_back:
	pushl $len_back_sure
	pushl $back_sure
	call quit
	addl $0x8, %esp

	testl %eax, %eax
	jz menu2_loop

menu2_yes_back:
	movl $-1, %eax
	jmp menu_end

menu2_yes_one:
	movl $0x1, %eax
	jmp menu2_end

menu2_yes_two:
	movl $0x2, %eax
	jmp menu2_end

menu2_yes_three:
	movl $0x3, %eax
	jmp menu2_end

menu2_yes_four:
	movl $0x4, %eax

menu2_end:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

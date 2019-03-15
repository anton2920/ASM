.equ STD_PERMS, 0666
.equ O_RDONLY, 0

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

menu2_line:
	.ascii " –––––––––––––––––––––––––––––––––––––––––––––––––––––––––––– \n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|                       >> Database <<                       |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|  >> Choose one of the following oprions:                   |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|       1) Show existing record                              |\n\0"
	.ascii "|       2) Add new record                                    |\n\0"
	.ascii "|       3) Delete existing record                            |\n\0"
	.ascii "|       4) Edit existing record                              |\n\0"
	.ascii "|                                                            |\n\0"
	.ascii "|       >> Type \"quit\" to terminate this program <<          |\n\0"
	.ascii "|                                                            |\n\0"

	.equ len_menu2_line, . - menu2_line
quit_sure:
	.ascii "| Are you sure you want to exit? [Y/n]: \0"
	.equ len_quit_sure, . - quit_sure
quit_err:
	.ascii "| menu: type \"y\" or \"n\"\n\0"
	.equ len_quit_err, . - quit_err

filename_line:
	.ascii "| Type filename: \0"
	.equ len_filename_line, . - filename_line

file_exists:
	.ascii "| database: file already exists\n\0"
	.equ len_file_exists, . - file_exists
change_name:
	.ascii "| Would you like to change filename? [Y/n]: \0"

.section .bss
.equ MENUBUF_LEN, 500
.lcomm MENUBUF, MENUBUF_LEN

.equ FILENAME_LEN, 500
.lcomm FILENAME, FILENAME_LEN

.section .text
.type prt_ln, @function
prt_ln:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	pushl $len_line
	pushl $line
	pushl $0x1
	call write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type quit, @function
quit:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

sure_quit:
	# I/O flow
	pushl $len_quit_sure
	pushl $quit_sure
	pushl $0x1
	call write
	addl $0xC, %esp

	pushl $MENUBUF_LEN
	push $MENUBUF
	pushl $0x0
	call read
	addl $0xC, %esp

	# Saving registers
	pushl %eax

	call prt_ln

	# Restoring registers
	popl %eax
	
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
	movl $-1, %eax

quit_exit:
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
	pushl $0x1
	call write
	addl $0xC, %esp

	pushl $len_answer
	pushl $answer
	pushl $0x1
	call write
	addl $0xC, %esp

	pushl $MENUBUF_LEN
	pushl $MENUBUF
	pushl $0x0
	call read
	addl $0xC, %esp

	pushl %eax
	call prt_ln
	popl %eax

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
	je call_quit

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
	pushl $len_no_cmd
	pushl $no_cmd
	pushl $0x1
	call write
	addl $0xC, %esp

	jmp menu_loop

call_quit:
	call quit

	cmpl $0x1, %eax
	je yes_quit

	cmpl $0x0, %eax
	je menu_loop

	cmpl $-1, %eax
	je menu_error

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

.globl create_database
.type create_database, @function
create_database: 
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing varibles

create_database_loop:
	# I/O flow
	pushl $len_filename_line
	pushl $filename_line
	pushl $0x1
	call write
	addl $0xC, %esp

	pushl $FILENAME_LEN
	pushl $FILENAME
	pushl $0x0
	call read
	addl $0xC, %esp

	movl $FILENAME, %ebx
	movb $0x0, (%ebx, %eax, 1)

	call prt_ln

	# Main part
	pushl $STD_PERMS
	pushl $O_RDONLY
	pushl $FILENAME
	call open
	addl $0xC, %esp

	#cmpl $0x0, %eax
	#je create_database_create

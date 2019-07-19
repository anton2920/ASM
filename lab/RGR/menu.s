.equ LIBC_ENABLED, 1

.equ STD_PERMS, 0666
.equ O_RDONLY, 0

.equ STDOUT, 1
.equ STDIN, 0

.equ sizeof_int, 4
.equ first_arg, sizeof_int + sizeof_int

.equ SEEK_SET, 0

.section .data
quit_line:
	.ascii "quit\n\0"
back_line:
	.asciz "back\n"
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

filename_line:
	.ascii "| Type filename: \0"
	.equ len_filename_line, . - filename_line

file_exists:
	.ascii "| database: file already exists                              |\n\0"
	.equ len_file_exists, . - file_exists
change_name:
	.ascii "| Would you like to change filename? [Y/n]: \0"
	.equ len_change_name, . - change_name
error_creating:
	.ascii "| database: error with creating database                     |\n\0"
	.equ len_error_creating, . - error_creating
lookout_for_cr:
	.ascii "| database: created successfully. Lookout for creation? [Y/n]: \0"
	.equ len_lookout_for_cr, . - lookout_for_cr
error_open:
	.ascii "| database: error with opening database                      |\n\0"
	.equ len_error_open, . - error_open
enter_pass:
	.asciz "| Type password: "
	.equ len_enter_pass, . - enter_pass
minus_one:
	.long -1
error_pass:
	.asciz "| database: paswords mismatch                                |\n"
	.equ len_error_pass, . - error_pass
pass_too_many:
	.asciz "| database: too many incorrect password attempts             |\n"
	.equ len_pass_too_many, . - pass_too_many
back_sure:
	.asciz "| Are you sure you want to close this database? [Y/n]: "
	.equ len_back_sure, . - back_sure
int_zero:
	.long 0

.section .bss
.equ MENUBUF_LEN, 500
.lcomm MENUBUF, MENUBUF_LEN

.equ FILENAME_LEN, 500
.lcomm FILENAME, FILENAME_LEN

.lcomm hash_sum, sizeof_int

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
	ret

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
	movl 8(%ebp), %eax
	movl 12(%ebp), %ebx

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
	ret

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
	movb $0x0, -1(%ebx, %eax, 1)

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

	test %eax, %eax
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

	test %eax, %eax
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
	jmp menu_end

menu_end:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp

	# Returning
	retl

.globl create_database
.type create_database, @function
create_database: 
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ fd, -4
	subl $0x4, %esp # Acquiring space in fd(%ebp)

	# Saving registers
	pushl %ebx

create_database_loop:
	# I/O flow
	pushl $len_filename_line
	pushl $filename_line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $FILENAME_LEN
	pushl $FILENAME
	pushl $0x0
	call read
	addl $0xC, %esp

	movl $FILENAME, %ebx
	movb $0x0, -1(%ebx, %eax, 1)

	call prt_ln

	# Main part
	pushl $STD_PERMS
	pushl $O_RDONLY
	pushl $FILENAME
	call open
	addl $0xC, %esp

	cmpl $0x0, %eax
	jle create_database_create

	jmp create_database_fileexists

create_database_create:
	pushl $STD_PERMS
	pushl $FILENAME
	call creat
	addl $0x8, %esp

	test %eax, %eax
	jle create_database_err

	# Saving registers
	movl %eax, fd(%ebp)

	# Ask for pass
	pushl $len_enter_pass
	pushl $enter_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

.if LIBC_ENABLED == 1
	pushl $0x0
	call turn_echo
	addl $0x4, %esp
.endif

	pushl $MENUBUF_LEN
	pushl $MENUBUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	# Saving registers
	pushl %eax

.if LIBC_ENABLED == 1
	pushl $0x1
	call turn_echo
	addl $0x4, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp
.endif

	call prt_ln

	# Restoring registers
	popl %eax

	pushl $sizeof_int

	cmpl $0x1, %eax
	jne make_hash_sum

	pushl $minus_one

	jmp create_database_lookout

make_hash_sum:
	pushl $MENUBUF
	call djb2
	addl $0x4, %esp

	movl %eax, hash_sum
	pushl $hash_sum

create_database_lookout:
	pushl fd(%ebp)
	call write
	addl $0xC, %esp

	pushl $sizeof_int
	pushl $int_zero
	pushl fd(%ebp)
	call write
	addl $0xC, %esp

	pushl $SEEK_SET
	pushl $0x0
	pushl fd(%ebp)
	call lseek
	addl $0xC, %esp

	pushl $len_lookout_for_cr
	pushl $lookout_for_cr
	call quit
	addl $0x8, %esp

	test %eax, %eax
	jz create_database_exit_1

	cmpl $0x1, %eax
	je create_database_exit_2

create_database_fileexists:
	pushl $len_file_exists
	pushl $file_exists
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp create_database_change_name

create_database_err:
	pushl len_error_creating
	pushl $error_creating
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

create_database_change_name:
	pushl $len_change_name
	pushl $change_name
	call quit
	addl $0x8, %esp

	# Saving registers
	pushl %eax

	call prt_ln

	# Restoring registers
	popl %eax

	cmpl $0x0, %eax
	je create_database_exit_1

	cmpl $0x1, %eax
	je create_database_loop

create_database_exit_1:
	call prt_ln

	pushl fd(%ebp)
	call close
	addl $0x4, %esp

	xorl %eax, %eax
	jmp create_database_exit

create_database_exit_2:
	# Returning value
	movl fd(%ebp), %eax

create_database_exit:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp

	# Returning
	retl

.globl open_database
.type open_database, @function
.equ PASS_ERR, -1
.equ LIM_ATT, 3
open_database:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ fd, -4
	.equ nattempts, -8
	subl $0x8, %esp # Acquiring space for two variables

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl $0x0, nattempts(%ebp)

open_database_loop:
	# I/O flow
	pushl $len_filename_line
	pushl $filename_line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $FILENAME_LEN
	pushl $FILENAME
	pushl $0x0
	call read
	addl $0xC, %esp

	movl $FILENAME, %ebx
	movb $0x0, -1(%ebx, %eax, 1)

open_database_open:
	# Main part
	pushl $STD_PERMS
	pushl $0x2
	pushl $FILENAME
	call open
	addl $0xC, %esp

	# Saving registers
	movl %eax, fd(%ebp)

	cmpl $0x0, %eax
	jg open_database_pass

open_database_err:
	call prt_ln

	pushl $len_error_open
	pushl $error_open
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

open_database_change_name:
	pushl $len_change_name
	pushl $change_name
	call quit
	addl $0x8, %esp

	# Saving registers
	pushl %eax

	call prt_ln

	# Restoring registers
	popl %eax

	cmpl $0x0, %eax
	je open_database_exit_1

	cmpl $0x1, %eax
	je open_database_loop

open_database_pass:
	call prt_ln

	pushl $sizeof_int
	pushl $hash_sum
	pushl fd(%ebp)
	call read
	addl $0xC, %esp

	cmpl $-1, hash_sum
	jz open_database_exit_2

	pushl $len_enter_pass
	pushl $enter_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

.if LIBC_ENABLED == 1
	pushl $0x0
	call turn_echo
	addl $0x4, %esp
.endif

	pushl $MENUBUF_LEN
	pushl $MENUBUF
	pushl $STDIN
	call read
	addl $0xC, %esp

.if LIBC_ENABLED
	pushl $0x1
	call turn_echo
	addl $0x4, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp
.endif

	pushl $MENUBUF
	call djb2
	addl $0x4, %esp

	cmpl %eax, hash_sum
	jz open_database_exit_2

	call prt_ln

	addl $0x1, nattempts(%ebp)

	cmpl $LIM_ATT, nattempts(%ebp)
	jg open_database_exit_error_pass

	pushl $len_error_pass
	pushl $error_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

	jmp open_database_pass

open_database_exit_1:
	xorl %eax, %eax
	jmp open_database_exit

open_database_exit_error_pass:
	pushl $len_pass_too_many
	pushl $pass_too_many
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl fd(%ebp)
	call close
	addl $0x4, %esp

	movl $PASS_ERR, %eax

	jmp open_database_exit

open_database_exit_2:
	pushl $SEEK_SET
	pushl $0x0
	pushl fd(%ebp)
	call lseek
	addl $0xC, %esp

	# Returning value
	movl fd(%ebp), %eax

open_database_exit:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp

	# Returning
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
	movb $0x0, -1(%ebx, %eax, 1)

	cmpl $0x5, %eax
	je menu2_check_quit

	cmpl $0x2, %eax
	je menu2_check_num

	jmp menu2_error

menu2_check_quit:
	pushl $quit_line
	pushl $MENUBUF
	call strcmp
	addl $0x8, %esp

	test %eax, %eax
	jz menu2_call_quit

	pushl $back_line
	pushl $MENUBUF
	call strcmp
	addl $0x8, %esp

	test %eax, %eax
	jz menu2_call_back

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
	addl $0xC, %esp

	test %eax, %eax
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

	test %eax, %eax
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

	# Returning
	retl

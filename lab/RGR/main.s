.include "constants.s"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ fd, -4
	subl $0x4, %esp # Acquiring space in fd(%ebp)

	# Initializing variables
	movl $0x0, fd(%ebp)

	# I/O flow
menu_l:
	call menu

	test %eax, %eax
	jz exit

	cmpl $0x1, %eax
	je create_new

	jmp open_exist

	# Main part
create_new:
	call create_database

	test %eax, %eax
	jz menu_l

	movl %eax, fd(%ebp)
	jmp menu2_l

open_exist:
	call open_database

	test %eax, %eax
	jz menu_l

	# cmpl $PASS_ERR, %eax
	# jz menu_l

	movl %eax, fd(%ebp)

menu2_l:
	call menu2

	test %eax, %eax
	jz close_l

	cmpl $-1, %eax
	jz close_and_back

	cmpl $0x1, %eax
	je menu2_1

	cmpl $0x2, %eax
	je menu2_2

	cmpl $0x3, %eax
	je menu2_3

	cmpl $0x4, %eax
	je menu2_4 

menu2_1:
	pushl fd(%ebp)
	call show_recs
	addl $0x4, %esp

	jmp menu2_ret_back

menu2_2:
	pushl fd(%ebp)
	call add_records
	addl $0x4, %esp
	
	jmp menu2_ret_back

menu2_3:
	pushl fd(%ebp)
	call delete_record
	jmp menu2_ret_back

menu2_4:
	pushl fd(%ebp)
	call edit_record
	addl $0x4, %esp

	jmp menu2_ret_back

menu2_ret_back:
	jmp menu2_l

close_and_back:
	pushl fd(%ebp)
	call close
	addl $0x4, %esp

	jmp menu_l

close_l:
	pushl fd(%ebp)
	call close
	addl $0x4, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.section .data

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp

	# Initializing variables

	# I/O flow
menu_l:
	call menu

	cmpl $0x0, %eax
	je exit

	cmpl $0x1, %eax
	je create_new

	xorl %eax, %eax
	jmp open_exist

	# Main part
create_new:
	call create_database

	cmpl $0x0, %eax
	je exit

open_exist:
	pushl %eax
	call open_database
	addl $0x4, %esp

	cmpl $0x0, %eax
	je exit

	# Saving registers
	pushl %eax # fd

menu2_l:
	call menu2
	addl $0x4, %esp

	cmpl $0x0, %eax
	je close_l

	cmpl $0x1, %eax
	je menu2_1

	cmpl $0x2, %eax
	je menu2_2

	cmpl $0x3, %eax
	je menu2_3

	cmpl $0x4, %eax
	je menu2_4 

menu2_1:
	popl %eax

	pushl %eax
	call show_recs
	addl $0x4, %esp

	jmp menu2_ret_back
menu2_2:
	jmp menu2_ret_back
menu2_3:
	jmp menu2_ret_back
menu2_4:
	jmp menu2_ret_back
menu2_ret_back:
	jmp menu2_l

close_l:
	pushl %eax
	call close
	addl $0x4, %esp

exit:
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

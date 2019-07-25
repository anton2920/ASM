.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ sizeof_int, 4
.equ first_param, sizeof_int + sizeof_int
.equ second_param, first_param + sizeof_int
.equ third_param, second_param + sizeof_int

.section .rodata
play_again:
	.asciz "\n| Do you want to play this file again? [y/N]: "
	.equ len_play_again, . - play_again
play_again_err:
	.asciz "| wavp: error! No such command!\n"
	.equ len_play_again_err, . - play_again_err

.section .bss 
.lcomm NUM_BUF, 500

.equ menubuf_len, 100
.lcomm menubuf, menubuf_len

.section .text
.globl write
.type write, @function
.equ SYS_WRITE, 4
.equ STDOUT, 1
write:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# I/O flow
    movl $SYS_WRITE, %eax # Write syscall
    movl first_param(%ebp), %ebx # File descriptor
    movl second_param(%ebp), %ecx # Buffer
    movl third_param(%ebp), %edx # Buffer size
    int $0x80 # 0x80's interrupt

    # Restoring registers
    popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl read
.type read, @function
.equ SYS_READ, 3
.equ STDIN, 0
read:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# I/O flow
    movl $SYS_READ, %eax # Read syscall
    movl first_param(%ebp), %ebx # File descriptor
    movl second_param(%ebp), %ecx # Buffer
    movl third_param(%ebp), %edx # Buffer size
    int $0x80 # 0x80's interrupt

    # Restoring registers
    popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl open
.type open, @function
.equ SYS_OPEN, 5
open:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Saving registers
	pushl %ebx

    # Syscall
    movl $SYS_OPEN, %eax # Open syscall
    movl first_param(%ebp), %ebx # File name
    movl second_param(%ebp), %ecx # Mode
    movl third_param(%ebp), %edx # Permissions
    int $0x80 # 0x80's interrupt

    # Restoring registers
    popl %ebx

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl close
.type close, @function
.equ SYS_CLOSE, 6
close:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Saving registers
	pushl %ebx

    # Syscall
    movl $SYS_CLOSE, %eax # Close syscall
    movl first_param(%ebp), %ebx # File descriptor
    int $0x80 # 0x80's interrupt

    # Restoring registers
    popl %ebx

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl ioctl
.type ioctl, @function
.equ SYS_IOCTL, 54
ioctl:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Syscall
	movl $SYS_IOCTL, %eax
	movl first_param(%ebp), %ebx
	movl second_param(%ebp), %ecx
	movl third_param(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Restoring registers
    popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl lstrlen
.type lstrlen, @function
lstrlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %esi
	pushl %edi

	# Initializing variables
	movl first_param(%ebp), %edi
	xorl %eax, %eax
	movl $0xFFFF, %ecx

	# Main part
	cld
	repnz scasb
	jne notfound

	subw $0xFFFF, %cx
	negw %cx
	decw %cx

	movl %ecx, %eax

	jmp lstrlen_fin

notfound:
	movl $-1, %eax

lstrlen_fin:
	# Restoring registers
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl lputchar
.type lputchar, @function
lputchar:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# I/O flow
	leal 8(%ebp), %eax
	movl $0x1, %ebx

	pushl %ebx 
	pushl %eax # &a
	pushl $STDOUT
	call write
	addl $0xC, %esp

	# Restoring registers
    popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl play_more
.type play_more, @function
play_more:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
play_more_begin:
	pushl $len_play_again
	pushl $play_again
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $menubuf_len
	pushl $menubuf
	pushl $STDIN
	call read
	addl $0xC, %esp

	leal menubuf, %edx

	xorl %ecx, %ecx
	movb (%edx), %cl

	cmpl $0x1, %eax
	jz test_nl

	cmpl $0x2, %eax
	jz test_yn

test_nl:
	cmpb $'\n', %cl
	jz ans_no

	jmp no_cmd

test_yn:
	cmpb $'Y', %cl
	jz ans_yes

	cmpb $'y', %cl
	jz ans_yes

	cmpb $'N', %cl
	jz ans_no

	cmpb $'n', %cl
	jz ans_no

	jmp no_cmd

ans_yes:
	xorl %eax, %eax
	incl %eax

	jmp play_more_exit

ans_no:
	xorl %eax, %eax

	jmp play_more_exit

no_cmd:
	pushl $len_play_again_err
	pushl $play_again_err
	pushl $STDERR
	call write
	addl $0xC, %esp

	jmp play_more_begin

play_more_exit:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl iprint
.type iprint, @function
iprint:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # Number

	# Main part
iprint_if:
	cmpl $0x0, %eax # if (a > 0)
	jg iprint_else

iprint_then:
	cmpl $0x0, %eax
	je iprint_print_0
	
	pushl %eax
	movl $'-', %edx
	pushl %edx
	call lputchar
	addl $0x4, %esp
	popl %eax

	imull $-1, %eax

iprint_else:
	pushl %eax

	pushl %eax
	call numlen
	addl $0x4, %esp

	popl %ebx
	pushl %eax

	pushl %eax
	pushl %ebx
	call reverse
	addl $0x8, %esp

	popl %eax
	imull $0x4, %eax
	pushl %eax
	pushl $NUM_BUF
	pushl $STDOUT
	call write
	addl $0xC, %esp
	jmp iprint_fin

iprint_print_0:
	movl $'0', %edx
	pushl %edx
	call lputchar
	addl $0x4, %esp

iprint_fin:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type reverse, @function # int and char *
reverse:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %eax # Number
	movl 12(%ebp), %ebx # Position
	decl %ebx
	movl $0xA, %ecx
	movl $NUM_BUF, %edi

	# Main part
reverse_main_loop:
	cmpl $0x0, %ebx
	jl reverse_main_loop_end

	xorl %edx, %edx
	idivl %ecx

	addl $'0', %edx
	movl %edx, (%edi, %ebx, 4)
	decl %ebx

	jmp reverse_main_loop

reverse_main_loop_end:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl find_size
.type find_size, @function
.equ SYS_LLSEEK, 140
find_size:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	subl $0x8, %esp

	# Saving registers
	pushl %esi
	pushl %edi
	pushl %ebx

	# Syscall
	movl $SYS_LLSEEK, %eax
	movl first_param(%ebp), %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx
	leal -8(%ebp), %esi
	movl $0x2, %edi
	int $0x80 # 0x80's interrupt

	# Returning value
	movl -8(%ebp), %eax

	# Restoring registers
	popl %ebx
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type numlen, @function
numlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	movl 8(%ebp), %eax # Number
	xorl %ebx, %ebx # Len
	movl $0xA, %ecx

numlen_loop:
	cmpl $0x0, %eax
	je numlen_loop_end

	xorl %edx, %edx
	idivl %ecx

	incl %ebx

	jmp numlen_loop

numlen_loop_end:
	movl %ebx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

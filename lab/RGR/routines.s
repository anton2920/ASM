.equ STDOUT, 1
.equ STDIN, 0

.equ sizeof_int, 4
.equ first_arg, sizeof_int + sizeof_int
.equ second_arg, first_arg + sizeof_int
.equ third_arg, second_arg + sizeof_int

.section .rodata
stty_arg_on:
	.asciz "stty echo"
stty_arg_off:
	.asciz "stty -echo"

.section .bss 
.lcomm NUM_BUF, 500

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
    movl first_arg(%ebp), %ebx # File descriptor
    movl second_arg(%ebp), %ecx # Buffer
    movl third_arg(%ebp), %edx # Buffer size
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
    movl first_arg(%ebp), %ebx # File descriptor
    movl second_arg(%ebp), %ecx # Buffer
    movl third_arg(%ebp), %edx # Buffer size
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
    movl first_arg(%ebp), %ebx # File name
    movl second_arg(%ebp), %ecx # Mode
    movl third_arg(%ebp), %edx # Permissions
    int $0x80 # 0x80's interrupt

    # Restoring registers
    popl %ebx

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl creat
.type creat, @function
creat:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl $0x241, %eax

	# Main part
	pushl second_arg(%ebp)
	pushl %eax
	pushl first_arg(%ebp)
	call open
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

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
    movl first_arg(%ebp), %ebx # File descriptor
    int $0x80 # 0x80's interrupt

    # Restoring registers
    popl %ebx

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    retl

.globl lseek
.type lseek, @function
.equ SYS_LSEEK, 19
lseek:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Syscall
	movl $SYS_LSEEK, %eax
	movl first_arg(%ebp), %ebx
	movl second_arg(%ebp), %ecx
	int $0x80 # 0x80's interrupt

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl strcmp
.type strcmp, @function
strcmp:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %eax
	movl second_arg(%ebp), %ebx

	# Main part
strcmp_loop:
	xorl %ecx, %ecx # c = 0
	xorl %edx, %edx # d = 0

	movb (%eax), %cl
	movb (%ebx), %dl
	cmpb %dl, %cl # if (*c != *d)
	jne strcmp_end_loop
	jz strcmp_end_loop

	incl %eax
	incl %ebx
	jmp strcmp_loop
	
strcmp_end_loop:
	subl %edx, %ecx # c -= d
	movl %ecx, %eax

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl atoi
.type atoi, @function
atoi:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ sign, -4
	subl $0x4, %esp # Acquiring space in sign(%ebp) — minus sign
	movl $0x1, sign(%ebp)

	# Saving registers
	pushl %ebx

	# Initializing variables
	.equ req_str, 8
	movl req_str(%ebp), %ebx
	xorl %ecx, %ecx # offset
	xorl %eax, %eax # res

	# Main part
atoi_if:
	xorl %edx, %edx
	movb (%ebx), %dl
	cmpb $'-', %dl # if (d == '-')
	jne atoi_if_2

atoi_then:
	movl $-1, sign(%ebp) # sign = 
	incl %ecx
	jmp atoi_main_loop

atoi_if_2:
	cmpb $'+', %dl # if (d == '+')
	jne atoi_main_loop

atoi_then_2:
	movl $0x1, sign(%ebp)
	incl %ecx

atoi_main_loop:
	xorl %edx, %edx
	movb (%ebx, %ecx, 1), %dl
	cmpb $0x0, %dl
	je atoi_main_loop_end

	subb $'0', %dl
	imull $0xA, %eax
	addl %edx, %eax

	incl %ecx

	jmp atoi_main_loop

atoi_main_loop_end:
	movl sign(%ebp), %edx
	imull %edx, %eax

	# Restoring registers
	popl %ebx

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
	movl first_arg(%ebp), %eax # Number

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

	popl %ecx
	pushl %eax

	pushl %eax
	pushl %ecx
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

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %eax # Number
	movl second_arg(%ebp), %ebx # Position
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
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl lputchar
.type lputchar, @function
lputchar:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	leal first_arg(%ebp), %eax
	movl $0x1, %ecx

	pushl %ecx 
	pushl %eax # &a
	pushl $STDOUT
	call write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type numlen, @function
numlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Main part
	movl first_arg(%ebp), %eax # Number
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

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl turn_echo
.type turn_echo, @function
.equ LIBC_ENABLED, 1
turn_echo:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %eax

.if LIBC_ENABLED == 1
	# Main part
	test %eax, %eax
	jz turn_echo_off

turn_echo_on:
	pushl $stty_arg_on
	
	jmp turn_echo_do

turn_echo_off:
	pushl $stty_arg_off

turn_echo_do:
	call system
	addl $0x4, %esp
.endif

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

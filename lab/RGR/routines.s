.include "constants.s"

.section .rodata
.if LIBC_ENABLED == 1
stty_arg_on:
	.asciz "stty echo"
stty_arg_off:
	.asciz "stty -echo"
#.else
#stty_name:
#	.asciz "stty"
#stty_arg_on:
#	.asciz "echo"
#stty_arg_off:
#	.asciz "-echo"
.endif

.section .bss 
.lcomm NUM_BUF, 500

.section .text
.globl write
.type write, @function
.equ SYS_WRITE, 4
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
	retl

.globl read
.type read, @function
.equ SYS_READ, 3
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
	retl

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
    retl

.globl access
.type access, @function
.equ SYS_ACCESS, 33
access:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Saving registers
    pushl %ebx

    # Syscall
    movl $SYS_ACCESS, %eax # Access syscall
    movl first_arg(%ebp), %ebx # File path
    movl second_arg(%ebp), %ecx # Access type
    int $0x80 # 0x80's interrupt

    # Restoring registers
    popl %ebx

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
	movl third_arg(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl lrewind
.type lrewind, @function
lrewind:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	pushl $SEEK_SET
	pushl $0x0
	movl first_arg(%ebp), %eax
	pushl %eax
	calll lseek
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl lstrcmp
.type lstrcmp, @function
lstrcmp:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %eax
	movl second_arg(%ebp), %edx
	subl %edx, %eax
	subl $0x10, %edx

	# Main part
sse4_strcmp_loop:
	addl $0x10, %edx
	movdqu (%edx), %xmm0

	pcmpistri $0b0011000, (%edx, %eax), %xmm0

	ja sse4_strlen_loop

	jc sse4_strcmp_diff

	xorl %eax, %eax # Strings are equal
	jmp sse4_strcmp_exit

sse4_strcmp_diff:
	addl %edx, %eax

	movzx (%eax, %ecx), %eax
	movzx (%edx, %ecx), %edx

	subl %edx, %eax

sse4_strcmp_exit:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl atoi
.type atoi, @function
atoi:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ sign, -4
	subl $0x4, %esp # Acquiring space in sign(%ebp) — minus sign

	# Saving registers
	pushl %esi
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %esi
	xorl %ecx, %ecx # offset
	xorl %ebx, %ebx # res
	movl $0x1, sign(%ebp)

	# Main part
atoi_if:
	xorl %eax, %eax
	cld
	lodsb

	cmpb $'-', %al # if (d == '-')
	jne atoi_if_2

atoi_then:
	movl $-1, sign(%ebp) # sign = -1
	jmp atoi_main_loop

atoi_if_2:
	cmpb $'+', %al # if (d == '+')
	je atoi_main_loop

atoi_then_2:
	decl %esi

atoi_main_loop:
	xorl %eax, %eax
	cld
	lodsb

	testb %al, %al
	jz atoi_main_loop_end

	subb $'0', %al
	imull $0xA, %ebx
	addl %eax, %ebx

	jmp atoi_main_loop

atoi_main_loop_end:
	movl sign(%ebp), %edx
	imull %edx, %ebx

	# Returning value
	movl %ebx, %eax

	# Restoring registers
	popl %ebx
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl
	
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
	testl %eax, %eax
	jnz iprint_print_not_0

	movl $'0', %edx
	pushl %edx
	calll lputchar
	addl $0x4, %esp

	jmp iprint_fin
	
iprint_print_not_0:
	# Saving registers
	pushl %eax

	pushl $'-'
	calll lputchar
	addl $0x4, %esp

	# Restoring registers
	popl %eax

	negl %eax

iprint_else:
	# Saving registers
	pushl %eax # Number

	pushl %eax
	calll numlen
	addl $0x4, %esp

	# Restoring registers
	popl %ecx # Number

	# Saving registers
	pushl %eax # Length

	pushl %eax # Length
	pushl %ecx # Number
	calll reverse
	addl $0x8, %esp

	# Restoring registers
	popl %eax # Length

	imull $0x4, %eax

	pushl %eax
	pushl $NUM_BUF
	pushl $STDOUT
	calll write
	addl $0xC, %esp

iprint_fin:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type reverse, @function # int and char *
reverse:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %edi
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %eax # Number
	movl second_arg(%ebp), %ebx # Position
	decl %ebx
	movl $0xA, %ecx
	movl $NUM_BUF, %edi

	# Main part
reverse_main_loop:
	testl %ebx, %ebx
	js reverse_main_loop_end

	xorl %edx, %edx
	idivl %ecx

	addl $'0', %edx
	movl %edx, (%edi, %ebx, 4)
	decl %ebx

	jmp reverse_main_loop

reverse_main_loop_end:
	# Restoring registers
	popl %ebx
	popl %edi

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

	# Initializing variables
	leal first_arg(%ebp), %eax

	# I/O flow
	pushl $0x1
	pushl %eax # &a
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl numlen
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
	testl %eax, %eax
	jz numlen_loop_end

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
.equ SYS_FORK, 2
.equ SYS_EXECVE, 11
turn_echo:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

.if LIBC_ENABLED == 1
	# Initializing variables
	movl first_arg(%ebp), %eax

	# Main part
	test %eax, %eax
	jz turn_echo_off

turn_echo_on:
	pushl $stty_arg_on
	
	jmp turn_echo_do

turn_echo_off:
	pushl $stty_arg_off

turn_echo_do:
	calll system
	addl $0x4, %esp
#.else
#	# Main part
#	movl $SYS_FORK, %eax
#	int $0x80 # 0x80's interrupt
#
#	movl first_arg(%ebp), %eax
#
#	test %eax, %eax
#	jz turn_echo_off
#
#turn_echo_on:
#	movl $stty_arg_on, %ecx
#	
#	jmp turn_echo_do
#
#turn_echo_off:
#	movl $stty_arg_off, %ecx
#
#turn_echo_do:
#	movl $stty_name, %ebx
#	movl $SYS_EXECVE, %eax
#	int $0x80 # 0x80's interrupt
.endif

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl get_file_size
.type get_file_size, @function
.equ SYS_LLSEEK, 140
get_file_size:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ ret_str, -8
	subl $0x8, %esp # Acquiring space for llseek return value

	# Saving registers
	pushl %esi
	pushl %edi
	pushl %ebx

	# Syscall
	movl $SYS_LLSEEK, %eax
	movl first_arg(%ebp), %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx
	leal ret_str(%ebp), %esi
	movl $0x2, %edi
	int $0x80 # 0x80's interrupt

	# Returning value
	movl ret_str(%ebp), %eax

	# Restoring registers
	popl %ebx
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl lstrncpy
.type lstrncpy, @function
lstrncpy:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %esi
	pushl %edi

	# Initializing variables
	movl first_arg(%ebp), %edi
	movl second_arg(%ebp), %esi
	movl third_arg(%ebp), %ecx
	movl %ecx, %edx # Save size

	subl %edi, %esi

	# Main part. SSE (SSE2)
	sarl $0x4, %ecx # Shift length by four (div by 16)

sse2_strncpy_while:
	test %ecx, %ecx
	jz sse2_strncpy_while_end

	movdqu (%esi, %edi), %xmm0
	movdqu %xmm0, (%edi)

	addl $0x10, %edi

	decl %ecx

	jmp sse2_strncpy_while

sse2_strncpy_while_end:
	addl %edi, %esi

	movl %edx, %ecx
	andl $0xF, %ecx
	
	cld
	rep movsl

	movl %edx, %ecx
	andl $0x3, %ecx

	rep movsb

	# Returning value
	movl first_arg(%ebp), %eax

	# Restoring registers
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl check_number
.type check_number, @function
check_number:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %esi

	# Initializing variables
	movl first_arg(%ebp), %esi

	# Main part
check_number_loop:
	xorl %eax, %eax
	cld
	lodsb

	testb %al, %al
	jz check_number_ok

	cmpb $'0', %al
	jl check_number_fail

	cmpb $'9', %al
	jg check_number_fail

	jmp check_number_loop

check_number_ok:
	movl $true, %eax

	jmp check_number_exit

check_number_fail:
	xorl %eax, %eax # false

check_number_exit:
	# Restoring registers
	popl %esi

	# Destroying function's stack frame
	movl %esp, %ebp
	popl %ebp
	retl

.globl lstrlen
.type lstrlen, @function
lstrlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	pxor %xmm0, %xmm0
	movl first_arg(%ebp), %edx
	movl $-16, %eax

	# Main part
sse4_strlen_loop:
	addl $0x10, %eax

	pcmpistri $0b0001000, (%edx, %eax), %xmm0

	jnz sse4_strlen_loop

sse4_strlen_loop_end:
	addl %ecx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

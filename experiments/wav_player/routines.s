.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ sizeof_int, 4
.equ first_param, sizeof_int + sizeof_int
.equ second_param, first_param + sizeof_int
.equ third_param, second_param + sizeof_int
.equ fourth_param, third_param + sizeof_int

# linux/soundcard.h
.equ SOUND_PCM_WRITE_BITS, 0xC0045005
.equ SOUND_PCM_WRITE_CHANNELS, 0xC0045006
.equ SOUND_PCM_WRITE_RATE, 0xC0045002
.equ SOUND_PCM_SYNC, 0x5001

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
	movl first_param(%ebp), %eax # Number

	# Main part
iprint_if:
	cmpl $0x0, %eax # if (a > 0)
	jg iprint_else

iprint_then:
	testl %eax, %eax
	jnz iprint_print_not_0

	pushl $'0'
	call lputchar
	addl $0x4, %esp

	jmp iprint_fin
	
iprint_print_not_0:
	# Saving registers
	pushl %eax

	pushl $'-'
	call lputchar
	addl $0x4, %esp

	# Restoring registers
	popl %eax

	negl %eax

iprint_else:
	# Saving registers
	pushl %eax # Number

	pushl %eax
	call numlen
	addl $0x4, %esp

	# Restoring registers
	popl %ecx # Number

	# Saving registers
	pushl %eax # Length

	pushl %eax # Length
	pushl %ecx # Number
	call reverse
	addl $0x8, %esp

	# Restoring registers
	popl %eax # Length

	# sall $0x2, %eax

	pushl %eax
	pushl $NUM_BUF
	pushl $STDOUT
	call write
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
	movl first_param(%ebp), %eax # Number
	movl second_param(%ebp), %ebx # Position
	decl %ebx
	movl $0xA, %ecx
	movl $NUM_BUF, %edi

	# Main part
reverse_main_loop:
	testl %ebx, %ebx
	js reverse_main_loop_end

	xorl %edx, %edx
	idivl %ecx

	addb $'0', %dl
	movb %dl, (%edi, %ebx)
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

.globl get_wav_info
.type get_wav_info, @function
get_wav_info:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %edi
	pushl %esi

	# Initializing variables
	movl first_param(%ebp), %eax # file
	movl second_param(%ebp), %ecx # rate
	movl third_param(%ebp), %edx # size
	movl fourth_param(%ebp), %edi # channels

	# Main part
	movl 24(%eax), %esi
	movl %esi, (%ecx)

	xorl %esi, %esi
	movw 34(%eax), %si
	movl $0x0, (%edx)
	movw %si, (%edx)

	xorl %esi, %esi
	movw 22(%eax), %si
	movl $0x0, (%edi)
	movw %si, (%edi)

	# Restoring registers
	popl %esi
	popl %edi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl tune_device
.type tune_device, @function
tune_device:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ arg, -4 # int
	subl $0x4, %esp # Acquiring space in arg(%ebp)

	# Initializing variables
	movl $0x0, arg(%ebp)
	movl first_param(%ebp), %eax # size

	# Main part
	movl %eax, arg(%ebp)
	leal arg(%ebp), %eax
	pushl %eax
	pushl $SOUND_PCM_WRITE_BITS
	pushl fourth_param(%ebp)
	call ioctl
	addl $0xC, %esp

	testl %eax, %eax
	js tune_device_error

	movl first_param(%ebp), %eax
	cmpl %eax, arg(%ebp)
	jne tune_device_error

	movl second_param(%ebp), %eax # chan
	movl %eax, arg(%ebp)
	leal arg(%ebp), %eax
	pushl %eax
	pushl $SOUND_PCM_WRITE_CHANNELS
	pushl fourth_param(%ebp)
	call ioctl
	addl $0xC, %esp

	testl %eax, %eax
	js tune_device_error

	movl second_param(%ebp), %eax
	cmpl %eax, arg(%ebp)
	jne tune_device_error

	movl third_param(%ebp), %eax # rate
	movl %eax, arg(%ebp)
	leal arg(%ebp), %eax
	pushl %eax
	pushl $SOUND_PCM_WRITE_RATE
	pushl fourth_param(%ebp)
	call ioctl
	addl $0xC, %esp

	testl %eax, %eax
	js tune_device_error

	movl third_param(%ebp), %eax
	cmpl %eax, arg(%ebp)
	je tune_device_ok

tune_device_error:
	movl $-1, %eax

	jmp tune_device_exit

tune_device_ok:
	# Returning value
	xorl %eax, %eax

tune_device_exit:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl get_proper_offset
.type get_proper_offset, @function
get_proper_offset:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables

	# Main part
	pushl first_param(%ebp)
	call atoi
	addl $0x4, %esp

	movl second_param(%ebp), %ecx
	imull %ecx, %eax

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
	movl first_param(%ebp), %esi
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

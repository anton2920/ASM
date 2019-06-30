.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2
.equ O_RDWR, 02
.equ O_RDONLY, 00

# Audio info
.equ RATE, 44100 # The sampling rate
.equ SIZE, 16 # Sample size: 8 or 16 bits
.equ CHANNELS, 2 # 1 — Mono, 2 — Stereo

# linux/soundcard.h
.equ SOUND_PCM_WRITE_BITS, 0xc0045005
.equ SOUND_PCM_WRITE_CHANNELS, 0xc0045006
.equ SOUND_PCM_WRITE_RATE, 0xc0045002
.equ SOUND_PCM_SYNC, 0x5001

.section .rodata
error_msg:
	.asciz "| wavp: error! Argument problem! Consider using only .wav filename\n"
	.equ len_error_msg, . - error_msg
hello:
	.asciz "| This is the simplest .wav player ever possible!\n| Enjoy your shitty music :)\n"
	.equ len_hello, . - hello
currently_playing:
	.asciz "\n| Currently playing: "
	.equ len_currently_playing, . - currently_playing
device:
	.asciz "/dev/dsp3"
un_err:
	.asciz "wavp: unexpected error occurs!\n"
	.equ len_un_err, . - un_err
play_again:
	.asciz "\n| Do you want to play this file again? [y/N]: "
	.equ len_play_again, . - play_again
play_again_err:
	.asciz "| wavp: error! No such command!\n"
	.equ len_play_again_err, . - play_again_err

.section .bss
.equ menubuf_len, 100
.lcomm menubuf, menubuf_len

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ fd, -4 # int
	.equ arg, -8 # int
	.equ file, -12 # int
	subl $0xC, %esp # Acquiring space for three variables

	.equ sizeof_buf, 176400 # void *
	.equ buf, -176412
	subl $sizeof_buf, %esp

	# Initializing variables
	movl (%ebp), %ecx
	cmpl $0x2, %ecx
	jnz arg_fault

	# I/O flow
	pushl $len_hello
	pushl $hello
	pushl $STDOUT
	call write
	addl $0xC, %esp

	# Main part
	pushl $O_RDWR
	pushl $device
	call open
	addl $0x8, %esp

	cmpl $0x0, %eax # If file isn't opened :(
	jle error

	movl %eax, fd(%ebp)

	movl $SIZE, arg(%ebp)
	leal arg(%ebp), %eax
	pushl %eax
	pushl $SOUND_PCM_WRITE_BITS
	movl fd(%ebp), %eax
	pushl %eax
	call ioctl
	addl $0xC, %esp

	cmpl $-1, %eax
	jz error

	cmpl $SIZE, arg(%ebp)
	jnz error

	movl $CHANNELS, arg(%ebp)
	leal arg(%ebp), %eax
	pushl %eax
	pushl $SOUND_PCM_WRITE_CHANNELS
	movl fd(%ebp), %eax
	pushl %eax
	call ioctl
	addl $0xC, %esp

	cmpl $-1, %eax
	jz error

	cmpl $CHANNELS, arg(%ebp)
	jnz error

	movl $RATE, arg(%ebp)
	leal arg(%ebp), %eax
	pushl %eax
	pushl $SOUND_PCM_WRITE_RATE
	movl fd(%ebp), %eax
	pushl %eax
	call ioctl
	addl $0xC, %esp

	cmpl $-1, %eax
	jz error

	cmpl $RATE, arg(%ebp)
	jnz error

	movl 8(%ebp), %eax
	pushl %eax

	pushl $O_RDONLY
	pushl %eax
	call open
	addl $0x8, %esp

	cmpl $0x0, %eax
	jle error

	movl %eax, file(%ebp)

replay_cont:
	pushl $len_currently_playing
	pushl $currently_playing
	pushl $STDOUT
	call write
	addl $0xC, %esp

	popl %eax
	pushl %eax

	pushl %eax
	call lstrlen
	addl $0x4, %esp

	popl %ebx
	pushl %eax
	pushl %ebx
	pushl $STDOUT
	call write
	addl $0xC, %esp

	movl $0xA, %eax
	pushl %eax
	call lputchar
	addl $0x4, %esp

main_while:
	pushl $sizeof_buf
	leal buf(%ebp), %eax
	pushl %eax
	movl file(%ebp), %eax
	pushl %eax
	call read
	addl $0xC, %esp

	cmpl $sizeof_buf, %eax
	jnz main_while_end

	pushl $sizeof_buf
	leal buf(%ebp), %eax
	pushl %eax
	movl fd(%ebp), %eax
	pushl %eax
	call write
	addl $0xC, %esp

	cmpl $sizeof_buf, %eax
	jnz main_while_end

	# pushl $0x0
	# pushl $SOUND_PCM_SYNC
	# movl fd(%ebp), %eax
	# pushl %eax
	# call ioctl
	# addl $0xC, %esp

	cmpl $-1, %eax
	jz main_while_end

	jmp main_while

main_while_end:

	call play_more

	cmpl $0x0, %eax
	jz closing

	movl 8(%ebp), %eax
	pushl %eax

	# Syscall
	movl $19, %eax
	movl file(%ebp), %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx
	int $0x80 # 0x80's interrupt

	jmp replay_cont

closing:
	movl fd(%ebp), %eax
	pushl %eax
	call close
	addl $0x4, %esp

	movl file(%ebp), %eax
	pushl %eax
	call close
	addl $0x4, %esp

	jmp exit

error:
	pushl $len_un_err
	pushl $un_err
	pushl $STDERR
	call write
	addl $0xC, %esp

	jmp exit

arg_fault:
	pushl $len_error_msg
	pushl $error_msg
	pushl $STDERR
	call write
	addl $0xC, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

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

	leal menubuf, %ebx

	xorl %ecx, %ecx
	movb (%ebx), %cl

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

.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2
.equ O_RDWR, 02
.equ O_RDONLY, 0

# Audio info
.equ RATE, 8000 # The sampling rate
.equ SIZE, 16 # Sample size: 8 or 16 bits
.equ CHANNELS, 2 # 1 — Mono, 2 — Stereo

# linux/soundcard.h
.equ SOUND_PCM_WRITE_BITS, 0x3221508101
.equ SOUND_PCM_WRITE_CHANNELS, 0x3221508102
.equ SOUND_PCM_WRITE_RATE, 0x3221508098
.equ SOUND_PCM_SYNC, 0x20481

.section .rodata
error_msg:
	.asciz "wavp: Error! Argument problem! Consider using only .wav filename\n"
	.equ len_error_msg, . - error_msg
hello:
	.asciz "This is the simples .wav player ever possible!\nEnjoy your shitty music :)\n"
	.equ len_hello, . - hello
currently_playing:
	.asciz "Currently playing: "
	.equ len_currently_playing, . - currently_playing
device:
	.asciz "/dev/dsp2"
un_err:
	.asciz "wavp: unexpected error occurs!\n"
	.equ len_un_err, . - un_err

.section .bss
.equ sizeof_buf, 32000
.lcomm buf, sizeof_buf

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ fd, -4 # int
	.equ arg, -8 # int
	.equ file, -12 # int
	subl $0xC, %esp # Acquiring space for three variables

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
	pushl $buf
	movl file(%ebp), %eax
	pushl %eax
	call read
	addl $0xC, %esp

	cmpl $sizeof_buf, %eax
	# jnz main_while_end
	jnz error

	pushl $sizeof_buf
	pushl $buf
	movl fd(%ebp), %eax
	pushl %eax
	call write
	addl $0xC, %esp

	cmpl $sizeof_buf, %eax
	jnz main_while_end

	pushl $0x0
	pushl $SOUND_PCM_SYNC
	movl fd(%ebp), %eax
	pushl %eax
	call ioctl
	addl $0xC, %esp

	cmpl $-1, %eax
	jz main_while_end

	jmp main_while

main_while_end:

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

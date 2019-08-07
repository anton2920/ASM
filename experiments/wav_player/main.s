.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2
.equ O_RDWR, 02
.equ O_RDONLY, 00
.equ PERMS, 0644

# Audio info
.equ RATE, 44100 # The sampling rate
.equ SIZE, 16 # Sample size: 8 or 16 bits
.equ CHANNELS, 2 # 1 — Mono, 2 — Stereo

# linux/soundcard.h
.equ SOUND_PCM_WRITE_BITS, 0xC0045005
.equ SOUND_PCM_WRITE_CHANNELS, 0xC0045006
.equ SOUND_PCM_WRITE_RATE, 0xC0045002
.equ SOUND_PCM_SYNC, 0x5001

.section .rodata
error_msg:
	.asciz "| wavp: error! Argument problem! Consider using only .wav filename\n"
	.equ len_error_msg, . - error_msg
hello:
	.asciz "| This is the simplest .wav player ever possible!\n| Enjoy your shitty music :)\n"
	.equ len_hello, . - hello
device:
	.asciz "/dev/dsp"
un_err:
	.asciz "\n| wavp: unexpected error occurs!\n"
	.equ len_un_err, . - un_err
presicion:
	.byte 0x7F, 0x02

.section .bss
.lcomm const_product, 4

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
	# .equ buf, -176412
	# subl $sizeof_buf, %esp

	# mmap approach
	.equ file_map, -16
	.equ file_size, -20
	subl $0x8, %esp

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

	# Main part. FPU
	finit
	fldcw presicion

	pushl $PERMS
	pushl $O_RDWR
	pushl $device
	call open
	addl $0xC, %esp

	testl %eax, %eax
	js error # If file isn't opened :(

	movl %eax, fd(%ebp)

	# Tune device
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

	pushl $CHANNELS
	pushl $SIZE
	pushl $RATE
	call print_dev_info
	addl $0xC, %esp

	movl $CHANNELS, %eax
	movl $SIZE, %ebx
	movl $RATE, %ecx
	imull %ebx, %eax
	imull %ecx, %eax
	shrl $0x3, %eax
	movl %eax, const_product

	# Open .wav file
	pushl $PERMS
	pushl $0102
	pushl 8(%ebp)
	call open
	addl $0xC, %esp

	test %eax, %eax
	js error

	movl %eax, file(%ebp)

	pushl file(%ebp)
	call find_size
	addl $0x4, %esp

	movl %eax, file_size(%ebp)

mmap_call:
	# Syscall
	pushl $0x0
	pushl file(%ebp)
	pushl $0x2 # Map private
	pushl $0x1 # Prot read-only
	pushl file_size(%ebp)
	pushl $0x0
	movl %esp, %ebx
	movl $90, %eax
	int $0x80 # 0x80's interrupt
	addl $0x18, %esp

	movl %eax, file_map(%ebp)

replay_cont:
	pushl 8(%ebp)
	call print_cur_play
	addl $0x4, %esp

	pushl file_size(%ebp)
	pushl const_product
	call print_file_info
	addl $0x8, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp

	xorl %ecx, %ecx

play_loop:
	cmpl %ecx, file_size(%ebp)
	jl play_loop_end

	# Saving registers
	pushl %ecx

	pushl $sizeof_buf
	movl file_map(%ebp), %edx
	leal (%edx, %ecx), %eax
	pushl %eax
	pushl fd(%ebp)
	call write
	addl $0xC, %esp

	# Restoring registers
	popl %ecx

	# Saving registers
	pushl %ecx

	pushl file_size(%ebp)
	pushl %ecx
	call print_progress_bar
	addl $0x8, %esp

	# Restoring registers
	popl %ecx

	addl $sizeof_buf, %ecx

	jmp play_loop

play_loop_end:
	pushl $'\n'
	call lputchar
	addl $0x4, %esp

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

	# Syscall
	pushl file_map(%ebp)
	pushl file_size(%ebp)
	movl $91, %eax
	int $0x80 # 0x80's interrupt

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

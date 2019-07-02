.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ sizeof_int, 4
.equ first_param, sizeof_int + sizeof_int
.equ second_param, first_param + sizeof_int
.equ third_param, second_param + sizeof_int

.section .rodata
info_rate:
	.asciz "\n| Device sampling rate: "
	.equ len_info_rate, . - info_rate
info_size:
	.asciz "| Device sample size: "
	.equ len_info_size, . - info_size
info_channels_stereo:
	.asciz "| Device channels: stereo\n"
	.equ len_info_channels_stereo, . - info_channels_stereo
info_channels_mono:
	.asciz "| Device channels: mono\n"
	.equ len_info_channels_mono, . - info_channels_mono
info_file_size:
	.asciz "| File size: "
	.equ len_info_file_size, . - info_file_size
info_file_duration:
	.asciz "| File duration: "
	.equ len_info_file_duration, . - info_file_duration
currently_playing:
	.asciz "\n| Currently playing: "
	.equ len_currently_playing, . - currently_playing
info_hz:
	.asciz " Hz\n"
	.equ len_info_hz, . - info_hz
info_bits:
	.asciz " bits\n"
	.equ len_info_bits, . - info_bits
info_kib:
	.asciz " kiB ("
	.equ len_info_kib, . - info_kib

.section .text
.globl print_dev_info
.type print_dev_info, @function
print_dev_info:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	pushl $len_info_rate
	pushl $info_rate
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl first_param(%ebp)
	call iprint
	addl $0x4, %esp

	pushl $len_info_hz
	pushl $info_hz
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $len_info_size
	pushl $info_size
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl second_param(%ebp)
	call iprint
	addl $0x4, %esp

	pushl $len_info_bits
	pushl $info_bits
	pushl $STDOUT
	call write
	addl $0xC, %esp

	movl third_param(%ebp), %eax
	cmpl $0x1, %eax
	jnz stereo_chan

	pushl $len_info_channels_mono
	pushl $info_channels_mono

	jmp end_if_chan

stereo_chan:
	pushl $len_info_channels_stereo
	pushl $info_channels_stereo

end_if_chan:
	pushl $STDOUT
	call write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl print_cur_play
.type print_cur_play, @function
print_cur_play:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	pushl $len_currently_playing
	pushl $currently_playing
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl first_param(%ebp)
	call lstrlen
	addl $0x4, %esp

	pushl %eax
	pushl first_param(%ebp)
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $0xA
	call lputchar
	addl $0x4, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl print_file_info
.type print_file_info, @function
print_file_info:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl first_param(%ebp), %ebx

	# Main part
	movl second_param(%ebp), %eax # file_size
	xorl %edx, %edx
	idivl %ebx # duration in seconds

	xorl %edx, %edx
	movl $60, %ebx
	idivl %ebx # eax - minutes, edx - seconds

	# Saving registers
	pushl %edx
	pushl %eax

	pushl $len_info_file_size
	pushl $info_file_size
	pushl $STDOUT
	call write
	addl $0xC, %esp

	movl second_param(%ebp), %eax
	shrl $0xA, %eax
	pushl %eax
	call iprint
	addl $0x4, %esp

	pushl $len_info_kib
	pushl $info_kib
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl second_param(%ebp)
	call iprint
	addl $0x4, %esp

	pushl $')'
	call lputchar

	pushl $0xA
	call lputchar
	addl $0x8, %esp

	pushl $len_info_file_duration
	pushl $info_file_duration
	pushl $STDOUT
	call write
	addl $0xC, %esp

	popl %eax
	pushl %eax
	call iprint

	pushl $'m'
	call lputchar

	pushl $' '
	call lputchar
	addl $0xC, %esp

	popl %eax
	pushl %eax
	call iprint

	pushl $'s'
	call lputchar

	pushl $'\n'
	call lputchar
	add $0x8, %esp

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

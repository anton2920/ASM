.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.equ sizeof_int, 4
.equ first_param, sizeof_int + sizeof_int
.equ second_param, first_param + sizeof_int
.equ third_param, second_param + sizeof_int

# Audio info
.equ WAV_HEADER_SIZE, 44

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
info_byte:
	.asciz " B\n"
	.equ len_info_byte, . - info_byte
hash:
	.ascii "="
hash2:
	.ascii "-"

.section .data
info_kib:
	.asciz " xiB ("
	.equ len_info_kib, . - info_kib
prog_bar:
	.ascii "\r| Progress: [                              ] "
	.equ len_prog_bar, . - prog_bar

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
	.equ hour_var, -4
	.equ minute_var, -8
	.equ second_var, -12
	subl $0xC, %esp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl first_param(%ebp), %ebx
	movl $0x0, hour_var(%ebp)
	movl second_param(%ebp), %eax # file_size
	subl $WAV_HEADER_SIZE, %eax
	xorl %edx, %edx

	# Main part
	idivl %ebx # duration in seconds

	xorl %edx, %edx
	movl $60, %ebx
	idivl %ebx # eax - minutes, edx - seconds
	movl %eax, minute_var(%ebp)
	movl %edx, second_var(%ebp)

	xorl %edx, %edx
	idivl %ebx

	testl %eax, %eax
	jz print_file_info_no_hr

	movl %eax, hour_var(%ebp)
	movl %edx, minute_var(%ebp)

print_file_info_no_hr:
	pushl $len_info_file_size
	pushl $info_file_size
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl second_param(%ebp)
	call proper_size
	addl $0x4, %esp

	testl %eax, %eax
	js print_file_info_byte

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

	jmp print_file_info_cont

print_file_info_byte:
	pushl second_param(%ebp)
	call iprint
	addl $0x4, %esp

	pushl $len_info_byte
	pushl $info_byte
	pushl $STDOUT
	call write
	addl $0xC, %esp
	
print_file_info_cont:
	pushl $len_info_file_duration
	pushl $info_file_duration
	pushl $STDOUT
	call write
	addl $0xC, %esp

	cmpl $0x0, hour_var(%ebp)
	je print_file_info_cont_cont
	
	pushl hour_var(%ebp)
	call iprint

	pushl $'h'
	call lputchar

	pushl $' '
	call lputchar
	addl $0xC, %esp

print_file_info_cont_cont:
	cmpl $0x0, minute_var(%ebp)
	je print_file_info_cont_cont_cont

	pushl minute_var(%ebp)
	call iprint

	pushl $'m'
	call lputchar

	pushl $' '
	call lputchar
	addl $0xC, %esp

print_file_info_cont_cont_cont:
	pushl second_var(%ebp)
	call iprint

	pushl $'s'
	call lputchar

	pushl $'\n'
	call lputchar
	add $0xC, %esp

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type proper_size, @function
proper_size:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl first_param(%ebp), %eax
	leal info_kib, %edx

	# Main part
proper_size_kib:
	shrl $0xA, %eax # div by 1024

	testl %eax, %eax
	jnz proper_size_mib

	xorl %eax, %eax
	decl %eax

	jmp proper_size_exit

proper_size_mib:
	shrl $0xA, %eax

	testl %eax, %eax
	jnz proper_size_gib

	movb $'k', 1(%edx)

	movl first_param(%ebp), %eax
	shrl $0xA, %eax

	jmp proper_size_exit

proper_size_gib:
	shrl $0xA, %eax

	testl %eax, %eax
	jnz proper_size_gib_ok

	movb $'M', 1(%edx)

	movl first_param(%ebp), %eax
	shrl $0x14, %eax

	jmp proper_size_exit

proper_size_gib_ok:
	movb $'G', 1(%edx)

proper_size_exit:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl print_progress_bar
.type print_progress_bar, @function
print_progress_bar:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ percent, -4
	subl $0x4, %esp # Acquiring space in percent(%ebp)

	# Saving registers
	pushl %edi
	pushl %ebx

	# Initializing variables
	movl first_param(%ebp), %eax
	movl second_param(%ebp), %ebx
	xorl %edx, %edx
	leal prog_bar, %edi
	addl $0xE, %edi

	# Main part
	fildl first_param(%ebp)
	fildl second_param(%ebp)
	fdivrp

	fst %st(1)

	subl $0x4, %esp
	movl $100, (%esp)

	fildl (%esp)
	fmulp # * 100%

	movl $0x1E, (%esp)
	fildl (%esp)
	fmulp %st(2) # * 30

	frndint
	fistpl percent(%ebp)

	frndint
	fistpl (%esp)

	movl (%esp), %ecx
	movl %ecx, %edx
	subl $0x1E, %edx
	negl %edx
	addl $0x4, %esp

	xorl %eax, %eax
	movb hash, %al

	cld
	rep stosb

	movb hash2, %al
	movl %edx, %ecx

	rep stosb

	pushl $len_prog_bar
	pushl $prog_bar
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl percent(%ebp)
	call iprint
	addl $0x4, %esp

	pushl $'%'
	call lputchar
	addl $0x4, %esp

	# Restoring registers
	popl %ebx
	popl %edi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

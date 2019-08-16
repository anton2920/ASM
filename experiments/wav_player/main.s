.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2
.equ O_RDWR, 02
.equ O_RDONLY, 00
.equ PERMS, 0644

# Audio info
.equ WAV_HEADER_SIZE, 44

.section .rodata
error_msg:
	.asciz "| wavp: error! Argument problem! Consider using only .wav filename\n"
	.equ len_error_msg, . - error_msg
hello:
	.asciz "| This is the simplest .wav player ever possible!\n| Enjoy your shitty music :)\n"
	.equ len_hello, . - hello
un_err:
	.asciz "\n| wavp: unexpected error occurs!\n"
	.equ len_un_err, . - un_err
presicion:
	.byte 0x7F, 0x02
device:
	.asciz "/dev/dsp3"

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ fd, -4 # int
	.equ file, -8 # int
	subl $0x8, %esp # Acquiring space for three variables

	.equ sizeof_buf, 176400 # void *
	# .equ buf, -176412
	# subl $sizeof_buf, %esp

	# mmap approach
	.equ file_map, -12 # void *
	.equ file_size, -16 # size_t
	subl $0x8, %esp

	.equ rate, -20 # int
	.equ size, -24 # int
	.equ chan, -28 # int
	subl $0xC, %esp

	subl $0x4, %esp # For 8-byte stack alignment

	.equ sec_off, -36
	subl $0x4, %esp

	# Initializing variables
	movl $0x0, rate(%ebp)
	movl $0x0, size(%ebp)
	movl $0x0, chan(%ebp)
	movl $0x0, sec_off(%ebp)
	
	cmpl $0x2, (%ebp)
	jl arg_fault

	cmpl $0x3, (%ebp)
	jg arg_fault

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

	# Open .wav file
	pushl $PERMS
	pushl $O_RDONLY
	pushl 8(%ebp)
	call open
	addl $0xC, %esp

	testl %eax, %eax
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

	# Tune device
	leal chan(%ebp), %eax
	pushl %eax
	leal size(%ebp), %eax
	pushl %eax
	leal rate(%ebp), %eax
	pushl %eax
	pushl file_map(%ebp)
	call get_wav_info
	addl $0x10, %esp

	pushl fd(%ebp)
	pushl rate(%ebp)
	pushl chan(%ebp)
	pushl size(%ebp)
	call tune_device
	addl $0x10, %esp

	testl %eax, %eax
	js error

	pushl chan(%ebp)
	pushl size(%ebp)
	pushl rate(%ebp)
	call print_dev_info
	addl $0xC, %esp

	cmpl $0x2, (%ebp)
	je replay_cont

	movl file_map(%ebp), %eax
	pushl 28(%eax) # const_product
	pushl 12(%ebp)
	call get_proper_offset
	addl $0x8, %esp

	movl %eax, sec_off(%ebp)

replay_cont:
	pushl 8(%ebp)
	call print_cur_play
	addl $0x4, %esp

	pushl file_size(%ebp)
	movl file_map(%ebp), %eax
	pushl 28(%eax) # const_product
	call print_file_info
	addl $0x8, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp

	movl sec_off(%ebp), %ecx

	subl $WAV_HEADER_SIZE, file_size(%ebp)

play_loop:
	cmpl %ecx, file_size(%ebp)
	jl play_loop_end

	# Saving registers
	pushl %ecx

	pushl $sizeof_buf
	movl file_map(%ebp), %edx
	leal WAV_HEADER_SIZE(%edx, %ecx), %eax
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
	movl $0x0, sec_off(%ebp)

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

	addl $WAV_HEADER_SIZE, file_size(%ebp)

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

.text
.p2align 4,,15
.type vga_mode_on, @function
.globl vga_mode_on
vga_mode_on:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	xorl %eax, %eax
	movb $0x13, %al
	int $0x10

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.size vga_mode_on, . - vga_mode_on

.p2align 4,,15
.globl vga_mode_off
.type vga_mode_off, @function
vga_mode_off:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	xorl %eax, %eax
	movb $0x03, %al
	int $0x10

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.size vga_mode_off, . - vga_mode_off

.equ vga_status_port, 0x3DA
.p2align 4,,15
.globl vga_wait_frame
.type vga_wait_frame, @function
vga_wait_frame:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	movl $vga_status_port, %edx

vga_wait_frame_wait_retrace:
	inb %dx, %al
	testb $0x8, %al
	jnz vga_wait_frame_wait_retrace

vga_wait_frame_end_refresh:
	inb %dx, %al
	testb $0x8, %al
	jz vga_wait_frame_end_refresh

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.size vga_wait_frame, . - vga_wait_frame

.equ rand_a, 1103515245
.equ rand_c, 12345
.equ rand_m, 0x7FFFFFFF

.p2align 4,,15
.globl rand
.type rand, @function
rand:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	movl $rand_seed, %eax
	movl $rand_a, %ecx
	imull %ecx, %eax	# rand_a * rand_seed 

	addl $rand_c, %eax 	# rand_a * rand_seed + rand_c
	xorl %edx, %edx
	movl $rand_m, %ecx

	idivl %ecx
	movl %edx, rand_seed

	# Returning value
	movl %edx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl
.size rand, . - rand

.section .data
rand_seed:
	.long 12345

.p2align 4,,15
.type tst, @function
.globl tst
tst:
	# Initializing stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ var_x, -4		# long
	.equ var_y, -8		# long
	.equ var_clr, -12	# byte
	.equ var_tm, -16	# byte
	subl $0x10, %esp

	# Main part
	call vga_mode_on

test_main_loop:
	# call vga_wait_frame

	# X-position
	call rand
	xorl %edx, %edx
	movl $320, %ecx
	idivl %ecx
	movl %edx, var_x(%ebp)

	# Y-position
	call rand
	xorl %edx, %edx
	movl $240, %ecx
	idivl %ecx
	movl %edx, var_y(%ebp)

	# Generating color
	call rand
	andl $0xFF, %eax

	# Writing pixel
	movb $0xC, %ah
	movw var_x(%ebp), %cx
	movw var_y(%ebp), %dx
	int $0x10

	movl $1000, %ecx

test_main_loop_delay:
	nop
	loop test_main_loop_delay

	xorl %eax, %eax
	movb $0x1, %ah
	int $0x16

	cmpb $0x39, %ah
	jne test_main_loop

test_main_loop_end:
	call vga_mode_off

test_exit:
	# Destroying stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.size tst, . - tst

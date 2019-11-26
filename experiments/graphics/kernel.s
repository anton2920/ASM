.text
.p2align 4,,15

.equ REGS, 26
.equ REGS_AX, 14
.equ REGS_CX, 12
.equ REGS_DX, 10

.type vga_mode_on, @function
.globl vga_mode_on
vga_mode_on:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ REGS_VAR, -REGS
	subl $REGS, %esp

	# Initializing variables
	movw $0x0013, REGS_VAR + REGS_AX(%ebp)

	# Main part
	#xorl %eax, %eax
	#movb $0x13, %al
	#int $0x10

	leal REGS_VAR, %eax
	pushl %eax
	subl $0x1, %esp
	movb $0x10, (%esp)
	call int32
	addl $0x5, %esp

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
	.equ REGS_VAR, -REGS
	subl $REGS, %esp

	# Initializing variables
	movw $0x0003, REGS_VAR + REGS_AX(%ebp)

	# Main part
	#xorl %eax, %eax
	#movb $0x13, %al
	#int $0x10

	leal REGS_VAR, %eax
	pushl %eax
	subl $0x1, %esp
	movb $0x10, (%esp)
	call int32
	addl $0x5, %esp
	
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
.type kernel_entry, @function
.globl kernel_entry
kernel_entry:
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
	#movb $0xC, %ah
	movw var_x(%ebp), %cx
	movw var_y(%ebp), %dx
	#int $0x10

	pushw %dx
	pushw %cx
	pushw %ax
	call plot_pixel
	addl $0x6, %esp

	movl $2000, %ecx

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

.equ VGA_ADDR, 0xA0000
.type plot_pixel, @function
.globl plot_pixel
plot_pixel:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movw 8(%ebp), %ax

	# Main part
	sarw $0x8, %ax
	movw 8(%ebp), %cx
	sarw $0x6, %cx
	addw %cx, %ax
	movw 10(%ebp), %cx
	addw %cx, %ax

	addl $VGA_ADDR, %eax

	movw 12(%ebp), %cx
	movb %cl, (%eax)

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.equ window_width, 366
.equ window_height, 391
.equ NULL, 0x0
.equ SDL_INIT_VIDEO, 0x00000020
.equ SDL_WINDOWPOS_CENTERED_MASK, 0x2FFF0000
.equ SDL_WINDOW_SHOWN, 0x00000004

.equ first_arg, 8
.equ second_arg, 12

.section .rodata
title:
	.asciz "Assemly and SDL2 fire sh**t"

.section .text
.type SDL_init_all, @function
.globl SDL_init_all
SDL_init_all:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl $SDL_INIT_VIDEO, %eax

	# Main part
	pushl %eax
	call SDL_Init
	addl $0x4, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.type Init_window_renderer, @function
.globl Init_window_renderer
Init_window_renderer:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	pushl $SDL_WINDOW_SHOWN
	pushl $window_height
	pushl $window_width
	pushl $SDL_WINDOWPOS_CENTERED_MASK
	pushl $SDL_WINDOWPOS_CENTERED_MASK
	pushl $title
	call SDL_CreateWindow
	addl $0x18, %esp

	cmpl $NULL, %eax
	jz em1_exit

	movl first_arg(%ebp), %ebx
	movl %eax, (%ebx) # Saving window *

	pushl $0x0
	pushl $-1
	pushl %eax
	call SDL_CreateRenderer
	addl $0xC, %esp

	cmpl $NULL, %eax
	jz em1_exit

	movl second_arg(%ebp), %ebx
	movl %eax, (%ebx) # Saving renderer *

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

em1_exit:
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type Get_texture, @function
.globl Get_texture
Get_texture:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl second_arg(%ebp), %eax

	# Main part
	pushl %eax
	call IMG_Load
	addl $0x4, %esp

	cmpl $NULL, %eax
	jz em2_exit

	pushl %eax
	pushl %eax
	movl first_arg(%ebp), %eax
	pushl %eax
	call SDL_CreateTextureFromSurface
	addl $0xC, %esp

	cmpl $NULL, %eax
	je em2_exit

	popl %ebx
	pushl %eax

	pushl %ebx
	call SDL_FreeSurface
	addl $0x4, %esp

	popl %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

em2_exit:
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

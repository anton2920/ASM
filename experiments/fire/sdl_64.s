.equ window_width, 366
.equ window_height, 391
.equ NULL, 0x0
.equ SDL_INIT_VIDEO, 0x00000020
.equ SDL_WINDOWPOS_CENTERED_MASK, 0x2FFF0000
.equ SDL_WINDOW_SHOWN, 0x00000004

.equ first_arg, 16
.equ second_arg, 24

.section .rodata
title:
	.asciz "Assemly and SDL2 fire sh**t"

.section .text
.type SDL_init_all, @function
.globl SDL_init_all
SDL_init_all:
	# Initializing function's stack frame
	pushq %rbp
	movq %rsp, %rbp

	# Initializing variables
	movq $SDL_INIT_VIDEO, %rax

	# Main part
	pushq %rax
	callq SDL_Init
	addq $0x8, %rax

	# Destroying function's stack frame
	movq %rbp, %rsp
	popq %rbp
	retq

.type Init_window_renderer, @function
.globl Init_window_renderer
Init_window_renderer:
	# Initializing function's stack frame
	pushq %rbp
	movq %rsp, %rbp

	# Main part
	pushq $SDL_WINDOW_SHOWN
	pushq $window_height
	pushq $window_width
	pushq $SDL_WINDOWPOS_CENTERED_MASK
	pushq $SDL_WINDOWPOS_CENTERED_MASK
	pushq $title
	callq SDL_CreateWindow
	addq $0x30, %rsp

	cmpq $NULL, %rax
	jz em1_exit

	movq first_arg(%rbp), %rbx
	movq %rax, (%rbx) # Saving window *

	pushq $0x0
	pushq $-1
	pushq %rax
	callq SDL_CreateRenderer
	addq $0x18, %rsp

	cmpq $NULL, %rax
	jz em1_exit

	movq second_arg(%rbp), %rbx
	movq %rax, (%rbx) # Saving renderer *

	# Destroying function's stack frame
	movq %rbp, %rsp
	popq %rbp
	retq

em1_exit:
	movq $60, %rax
	xorq %rdi, %rdi
	syscall

.type Get_texture, @function
.globl Get_texture
Get_texture:
	# Initializing function's stack frame
	pushq %rbp
	movq %rsp, %rbp

	# Initializing variables
	movq second_arg(%rbp), %rax

	# Main part
	pushq %rax
	callq IMG_Load
	addq $0x8, %rsp

	cmpq $NULL, %rax
	jz em2_exit

	pushq %rax
	pushq %rax
	movq first_arg(%rbp), %rax
	pushq %rax
	callq SDL_CreateTextureFromSurface
	addq $0x18, %rsp

	cmpq $NULL, %rax
	je em2_exit

	popq %rbx
	pushq %rax

	pushq %rbx
	callq SDL_FreeSurface
	addq $0x8, %rsp

	popq %rax

	# Destroying function's stack frame
	movq %rbp, %rsp
	popq %rbp
	retq

em2_exit:
	movq $60, %rax
	xorq %rdi, %rdi
	syscall

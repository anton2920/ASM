.equ window_width, 366
.equ window_height, 391

.equ NULL, 0x0
.equ SDL_INIT_EVERYTHING, 0xf231
.equ SDL_WINDOWPOS_CENTERED_MASK, 0x2FFF0000
.equ SDL_WINDOW_SHOWN, 0x4

.equ first_arg, -16
.equ second_arg, -8

.section .rodata
prog_title:
	.asciz "Assemly and SDL2 fire sh**t"

.section .text
.type SDL_init_all, @function
.globl SDL_init_all
SDL_init_all:
	# Initializing function's stack frame
	pushq %rbp
	movq %rsp, %rbp

	# Initializing variables
	movl $SDL_INIT_EVERYTHING, %edi

	# Main part
	callq SDL_Init@PLT

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
	pushq %rsi # Second parameter
	pushq %rdi # First parameter

	# Main part
	movl $SDL_WINDOW_SHOWN, %r9d
	movl $window_height, %r8d
	movl $window_width, %ecx
	movl $SDL_WINDOWPOS_CENTERED_MASK, %edx
	movl $SDL_WINDOWPOS_CENTERED_MASK, %esi
	leaq prog_title(%rip), %rdi
	callq SDL_CreateWindow@PLT

	cmpq $NULL, %rax
	jz em1_exit

	movq first_arg(%rbp), %rbx
	movq %rax, (%rbx) # Saving window *

	xorq %rdx, %rdx
	movq $-1, %rsi
	movq %rax, %rdi
	callq SDL_CreateRenderer@PLT

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
	pushq %rsi # Second parameter
	pushq %rdi # First parameter

	# Initializing variables
	movq second_arg(%rbp), %rdi

	# Main part
	callq IMG_Load@PLT

	cmpq $NULL, %rax
	jz em2_exit

	pushq %rax

	movq %rax, %rsi
	movq first_arg(%rbp), %rdi
	callq SDL_CreateTextureFromSurface@PLT

	cmpq $NULL, %rax
	je em2_exit

	popq %rbx
	pushq %rax

	movq %rbx, %rdi
	callq SDL_FreeSurface@PLT

	popq %rax

	# Destroying function's stack frame
	movq %rbp, %rsp
	popq %rbp
	retq

em2_exit:
	movq $60, %rax
	xorq %rdi, %rdi
	syscall

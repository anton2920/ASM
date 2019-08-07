.equ delay_time, 40

.equ sizeof_void_p, 8
.equ sizeof_int, 4

.equ pic_inc, 366
.equ pic_max, 4758

# struct SDL_Rect {
#	int x, y, w, h;
#}

.equ sizeof_sdl_rect, 16
.equ rect_x, 0
.equ rect_y, 4
.equ rect_w, 8
.equ rect_h, 12

.equ sizeof_sdl_event, 56
.equ event_type, 0
.equ SDL_QUIT, 0x100

.section .rodata
pic_path:
	.asciz "giphy.png"

.section .text
.globl main
.type main, @function
main:
# .globl _start
# _start:
	# Initializing function's stack frame
	pushq %rbp
	movq %rsp, %rbp
	.equ num_of_vars, sizeof_void_p + sizeof_void_p
	.equ window, -8 # SDL_Window *
	.equ renderer, -16 # SDL_Renderer * 
	subq $num_of_vars, %rsp

	.equ draw_rect, -32 # SDL_Rect
	.equ curr_rect, -48 # SDL_Rect
	subq $sizeof_sdl_rect, %rsp
	subq $sizeof_sdl_rect, %rsp

	subq $0x8, %rsp # For stack alignment

	.equ fire_texture, -64 # SDL_Texture *
	subq $sizeof_void_p, %rsp

	subq $0x8, %rsp # For stack alignment

	.equ event, -128 # SDL_Event
	subq $sizeof_sdl_event, %rsp

	subq $0xC, %rsp # For stack alignment

	.equ quit_flag, -144 # int
	subq $sizeof_int, %rsp

	# Initializing variables
	movq $0x0, draw_rect + rect_x(%rbp)
	movq $0x0, draw_rect + rect_y(%rbp)
	movq $316, draw_rect + rect_w(%rbp)
	movq $391, draw_rect + rect_h(%rbp)
	movq $0x0, curr_rect + rect_x(%rbp)
	movq $0x0, curr_rect + rect_y(%rbp)
	movq $316, curr_rect + rect_w(%rbp)
	movq $391, curr_rect + rect_h(%rbp)
	movl $0x0, quit_flag(%rbp)

	# Main part. SDL2
	callq SDL_init_all # Initializing SDL2

	# Initializing windows and attaching renderer to it
	leaq renderer(%rbp), %rsi
	leaq window(%rbp), %rdi
	callq Init_window_renderer

	leaq pic_path(%rip), %rsi
	movq renderer(%rbp), %rdi
	callq Get_texture

	movq %rax, fire_texture(%rbp) # Saving texture to variable

main_while_loop:
	cmpl $0x0, quit_flag(%rbp) # if (flag)
	jnz main_while_end

event_loop:
	leaq event(%rbp), %rdi
	callq SDL_PollEvent

	cmpq $0x0, %rax
	jz event_loop_end

	movl event + event_type(%rbp), %eax
	cmpl $SDL_QUIT, %eax
	jnz event_loop

	movl %eax, quit_flag(%rbp)

event_loop_end:
	movq renderer(%rbp), %rdi
	call SDL_RenderClear

	leaq draw_rect(%rbp), %rcx
	leaq curr_rect(%rbp), %rdx
	movq fire_texture(%rbp), %rsi
	movq renderer(%rbp), %rdi
	callq SDL_RenderCopy

	movq renderer(%rbp), %rdi
	call SDL_RenderPresent

	xorq %rcx, %rcx

	movq curr_rect + rect_x(%rbp), %rax
	addq $pic_inc, %rax
	cmpq $pic_max, %rax
	cmovz %rcx, %rax
	movq %rax, curr_rect + rect_x(%rbp)

	movl $delay_time, %edi
	callq SDL_Delay

	jmp main_while_loop

main_while_end:
	movq fire_texture(%rbp), %rdi
	callq SDL_DestroyTexture

	movq renderer(%rbp), %rdi
	callq SDL_DestroyRenderer

	movq window(%rbp), %rdi
	callq SDL_DestroyWindow

	# Destroying function's stack frame
	movq %rbp, %rsp
	popq %rbp
	retq

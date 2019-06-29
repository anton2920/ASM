.equ run_time, 30000
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

.section .rodata
pic_path:
	.asciz "giphy.png"

.section .text
.globl main
main:
	# Initializing stack frame
	movq %rsp, %rbp
	.equ num_of_vars, sizeof_void_p + sizeof_void_p
	.equ window, -8 # SDL_Window *
	.equ renderer, -16 # SDL_Renderer * 
	subq $num_of_vars, %rsp

	.equ draw_rect, -32 # SDL_Rect
	.equ curr_rect, -48 # SDL_Rect
	subq $sizeof_sdl_rect, %rsp
	subq $sizeof_sdl_rect, %rsp

	.equ fire_texture, -56 # SDL_Texture *
	subq $sizeof_void_p, %rsp

	# Initializing variables
	movq $0x0, draw_rect + rect_x(%rbp)
	movq $0x0, draw_rect + rect_y(%rbp)
	movq $316, draw_rect + rect_w(%rbp)
	movq $391, draw_rect + rect_h(%rbp)
	movq $0x0, curr_rect + rect_x(%rbp)
	movq $0x0, curr_rect + rect_y(%rbp)
	movq $316, curr_rect + rect_w(%rbp)
	movq $391, curr_rect + rect_h(%rbp)

	# Main part. SDL2	
	callq SDL_init_all # Initializing SDL2

	# Initializing windows and attaching renderer to it
	leaq renderer(%rbp), %rsi
	leaq window(%rbp), %rdi
	callq Init_window_renderer

	movq $pic_path, %rsi
	movq renderer(%rbp), %rdi
	callq Get_texture

	movq %rax, fire_texture(%rbp) # Saving texture to variable

main_while:
	callq SDL_GetTicks
	cmpq $run_time, %rax # if (ticks > run_time)
	jae main_while_end

	movq renderer(%rbp), %rdi
	call SDL_RenderClear

	leaq draw_rect(%rbp), %rcx
	leaq curr_rect(%rbp), %rdx
	movq fire_texture(%rbp), %rsi
	movq renderer(%rbp), %rdi
	callq SDL_RenderCopy

	xorq %rcx, %rcx

	movq curr_rect + rect_x(%rbp), %rax
	addq $pic_inc, %rax
	cmpq $pic_max, %rax
	cmovg %rcx, %rax
	movq %rax, curr_rect + rect_x(%rbp)

	movq renderer(%rbp), %rdi
	call SDL_RenderPresent

	movl $delay_time, %edi
	callq SDL_Delay

	jmp main_while

main_while_end:
	movq fire_texture(%rbp), %rdi
	callq SDL_DestroyTexture

	movq renderer(%rbp), %rdi
	callq SDL_DestroyRenderer

	movq window(%rbp), %rdi
	callq SDL_DestroyWindow

exit:
	# Exiting
	movq $60, %rax
	xorq %rdi, %rdi
	syscall

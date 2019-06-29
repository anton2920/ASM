.equ run_time, 30000
.equ delay_time, 40

.equ sizeof_int, 4
.equ sizeof_void_p, 4

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
main:
	# Initializing stack frame
	movl %esp, %ebp
	.equ num_of_vars, sizeof_void_p + sizeof_void_p
	.equ window, -4 # SDL_Window *
	.equ renderer, -8 # SDL_Renderer *
	subl $num_of_vars, %esp

	.equ draw_rect, -24 # SDL_Rect
	.equ curr_rect, -40 # SDL_Rect
	subl $sizeof_sdl_rect, %esp
	subl $sizeof_sdl_rect, %esp

	.equ fire_texture, -44 # SDL_Texture *
	subl $sizeof_void_p, %esp

	.equ event, -100 # SDL_Event
	subl $sizeof_sdl_event, %esp

	.equ quit_flag, -104 # int
	subl $sizeof_int, %esp

	# Initializing variables
	movl $0x0, draw_rect + rect_x(%ebp)
	movl $0x0, draw_rect + rect_y(%ebp)
	movl $316, draw_rect + rect_w(%ebp)
	movl $391, draw_rect + rect_h(%ebp)
	movl $0x0, curr_rect + rect_x(%ebp)
	movl $0x0, curr_rect + rect_y(%ebp)
	movl $316, curr_rect + rect_w(%ebp)
	movl $391, curr_rect + rect_h(%ebp)

	# Main part. SDL2	
	call SDL_init_all # Initializing SDL2

	# Initializing windows and attaching renderer to it
	leal renderer(%ebp), %eax
	pushl %eax
	leal window(%ebp), %eax
	pushl %eax
	call Init_window_renderer
	addl $sizeof_void_p + sizeof_void_p, %esp

	pushl $pic_path
	pushl renderer(%ebp)
	call Get_texture
	addl $sizeof_void_p + sizeof_void_p, %esp

	movl %eax, fire_texture(%ebp) # Saving texture to variable

main_while:
	cmpl $0x0, quit_flag(%ebp) # if (flag)
	jnz main_while_end

event_loop:
	leal event(%ebp), %eax
	pushl %eax
	call SDL_PollEvent
	addl $sizeof_void_p, %esp

	cmpl $0x0, %eax
	jz event_loop_end

	movl event + event_type(%ebp), %eax
	cmpl $SDL_QUIT, %eax
	jnz event_loop

	movl %eax, quit_flag(%ebp)

event_loop_end:
	movl renderer(%ebp), %eax
	pushl %eax
	call SDL_RenderClear
	addl $sizeof_void_p, %esp

	leal draw_rect(%ebp), %eax
	pushl %eax
	leal curr_rect(%ebp), %eax
	pushl %eax
	movl fire_texture(%ebp), %eax
	pushl %eax
	movl renderer(%ebp), %eax
	pushl %eax
	call SDL_RenderCopy
	addl $sizeof_void_p + sizeof_void_p + sizeof_void_p + sizeof_void_p, %esp

	movl renderer(%ebp), %eax
	pushl %eax
	call SDL_RenderPresent
	addl $sizeof_void_p, %esp

	xorl %ecx, %ecx

	movl curr_rect + rect_x(%ebp), %eax
	addl $pic_inc, %eax
	cmpl $pic_max, %eax
	cmovz %ecx, %eax
	movl %eax, curr_rect + rect_x(%ebp)

	pushl $delay_time
	call SDL_Delay
	addl $sizeof_int, %esp
	jmp main_while

main_while_end:
	movl fire_texture(%ebp), %eax
	pushl %eax
	call SDL_DestroyTexture
	addl $sizeof_void_p, %esp

	movl renderer(%ebp), %eax
	pushl %eax
	call SDL_DestroyRenderer
	addl $sizeof_void_p, %esp

	movl window(%ebp), %eax
	pushl %eax
	call SDL_DestroyWindow
	addl $sizeof_void_p, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

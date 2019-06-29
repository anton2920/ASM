.equ run_time, 30000
.equ delay_time, 40
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

.section .rodata
pic_path:
	.asciz "giphy.png"

.section .text
.globl main
main:
	# Initializing stack frame
	movl %esp, %ebp
	.equ num_of_vars, 8
	.equ window, -4
	.equ renderer, -8
	subl $num_of_vars, %esp

	.equ draw_rect, -24
	.equ curr_rect, -40
	subl $sizeof_sdl_rect, %esp
	subl $sizeof_sdl_rect, %esp

	.equ fire_texture, -44
	subl $sizeof_void_p, %esp

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
	addl $0x8, %esp

	pushl $pic_path
	pushl renderer(%ebp)
	call Get_texture
	addl $0x8, %esp

	movl %eax, fire_texture(%ebp) # Saving texture to variable

main_while:
	call SDL_GetTicks
	cmpl $run_time, %eax # if (ticks > run_time)
	jae main_while_end

	leal draw_rect(%ebp), %eax
	pushl %eax
	leal curr_rect(%ebp), %eax
	pushl %eax
	movl fire_texture(%ebp), %eax
	pushl %eax
	movl renderer(%ebp), %eax
	pushl %eax
	call SDL_RenderCopy
	addl $0x10, %esp

	xorl %ecx, %ecx

	movl curr_rect + rect_x(%ebp), %eax
	addl $pic_inc, %eax
	cmpl $pic_max, %eax
	cmovg %ecx, %eax
	movl %eax, curr_rect + rect_x(%ebp)

	pushl $delay_time
	call SDL_Delay
	addl $0x4, %esp
	jmp main_while

main_while_end:
	movl fire_texture(%ebp), %eax
	pushl %eax
	call SDL_DestroyTexture
	addl $0x4, %esp

	movl renderer(%ebp), %eax
	pushl %eax
	call SDL_DestroyRenderer
	addl $0x4, %esp

	movl window(%ebp), %eax
	pushl %eax
	call SDL_DestroyWindow
	addl $0x4, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

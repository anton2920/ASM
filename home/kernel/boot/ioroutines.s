prints:
	# Initializing function's stack frame
	pushw %bp
	movw %sp, %bp

	# Initializing variables
	movb $0xE, %ah # Teletype write to active page
	movw 4(%bp), %si
	cld

prints_loop:
	lodsb
	testb %al, %al
	jz prints_loop_end

	int $0x10

	jmp prints_loop

prints_loop_end:
	movw %bp, %sp
	popw %bp
	retw

printw:
	# Initializing function's stack frame
	pushw %bp
	movw %sp, %bp

	# Initializing variables
	movw 4(%bp), %dx
	leaw printw_out + printw_out_len - 2, %di
	std

	movb $'0', printw_out + 2
	movb $'0', printw_out + 3
	movb $'0', printw_out + 4
	movb $'0', printw_out + 5

printw_loop:
	testw %dx, %dx
	jz printw_loop_end

	movw %dx, %ax
	andw $0xF, %ax

	cmpb $0xA, %al
	jb printw_if_else

	subb $0xA, %al
	addb $'A', %al

	jmp printw_if_fi

printw_if_else:
	addb $'0', %al

printw_if_fi:
	stosb

	shrw $0x4, %dx
	jmp printw_loop

printw_loop_end:
	pushw $printw_out
	callw prints
	# addw $0x2, %sp

	movw %bp, %sp
	popw %bp
	retw

# .section .data
printw_out:
	.asciz "0x0000"
	.equ printw_out_len, . - printw_out

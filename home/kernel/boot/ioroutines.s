# void prints(const char *);
prints:
	movb $0xE, %ah # Teletype write to active page
	movw %di, %si
	cld

prints_loop:
	lodsb
	testb %al, %al
	jz prints_loop_end

	int $0x10

	jmp prints_loop

prints_loop_end:
	retw

# void printw(short);
printw:
	movw %di, %dx
	leaw printw_out_str + printw_out_str_len - 2, %di
	std

	movb $'0', printw_out_str + 2
	movb $'0', printw_out_str + 3
	movb $'0', printw_out_str + 4
	movb $'0', printw_out_str + 5

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
	leaw printw_out_str, %di
	callw prints

	retw

# .section .data
printw_out_str:
	.asciz "0x0000"
	.equ printw_out_str_len, . - printw_out_str

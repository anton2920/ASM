# if_cond: #[optimized a bit version]
# cmp{b, w, l} ..., ...
# j{a, b, c, e, g, l, ...} else_branch # inverse condition

# then_branch:

# 	jmp end_if

# else_branch:

# end_if:

.equ size_x, 45
.equ size_y, 0x12
.equ start_sh, size_x - 14

.section .rodata
format_left_bracket:
	.asciz "["
format_right_bracket:
	.asciz "]"
format_colon:
	.asciz ":"
format_space:
	.asciz " "
format_university:
	.asciz "BSTU"
format_group:
	.asciz "18-SWE"
format_name:
	.asciz "Pavlovsky Anton Evgenevich"
format_newline:
	.asciz "\n"

.section .text
.globl _start
_start:	
	# Initializing stack frame
	movl %esp, %ebp

	# Initializing variables
	xorl %eax, %eax # First (outer) iterator
	xorl %ebx, %ebx # Second (inner) iterator

	xorl %edi, %edi # Flag
	xorl %esi, %esi # Second flag

	xorl %ecx, %ecx # «Zero» value
	xorl %edx, %edx # «One value
	incl %edx 

	# Main part
for_a:
	cmpl $size_y, %eax
	jg for_a_end

for_b:
	cmpl $size_x, %ebx
	jg for_b_end

	# Many if's
left_bracket:
	# c: if ((line == 0x0 || line == 0x12) && col <= 0xE)
	cmpl $0x0, %eax
	cmovnel %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0x12, %eax
	cmovnel %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi

	cmpl $0xE, %ebx
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	je left_bracket_main

	# c: if ((line == 3 || line == 0xF) && col >= 0x7 && col <= 0xD)
	cmpl $0x3, %eax
	cmovnel %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0xF, %eax
	cmovnel %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi

	cmpl $0x7, %ebx
	cmovll %ecx, %esi
	cmovgel %edx, %esi

	andl %esi, %edi

	cmpl $0xD, %ebx
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	je left_bracket_main

	# c: if (line >= 0x4 && line <= 0xE && col == 0x6)
	cmpl $0x4, %eax
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $0xE, %eax
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi

	cmpl $0x6, %ebx
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	andl %esi, %edi

	# c: if (col == 0)
	cmpl $0x0, %ebx
	cmovz %edx, %edi

	cmpl $0x1, %edi
	jnz right_bracket

left_bracket_main:
	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_left_bracket
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	jmp for_b_done

right_bracket:
	# c: if ((line == 0x0 || line == 0x12) && col >= start_sh)
	cmpl $0x0, %eax
	cmovnel %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0x12, %eax
	cmovnel %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi

	cmpl $start_sh, %ebx
	cmovll %ecx, %esi
	cmovgel %edx, %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	je right_bracket_main

	# c: if ((line == 3 || line == 0xF) && col >= start_sh + 1 && col <= start_sh + 7)
	cmpl $0x3, %eax
	cmovnel %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0xF, %eax
	cmovnel %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi

	cmpl $start_sh + 1, %ebx
	cmovll %ecx, %esi
	cmovgel %edx, %esi

	andl %esi, %edi

	cmpl $start_sh + 7, %ebx
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	je right_bracket_main

	# c: if (line >= 0x4 && line <= 0xE && col == start_sh + 8)
	cmpl $0x4, %eax
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $0xE, %eax
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi

	cmpl $start_sh + 8, %ebx
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	andl %esi, %edi

	# c: if (col == size_y)
	cmpl $size_x, %ebx
	cmovz %edx, %edi

	cmpl $0x1, %edi
	jnz colon

right_bracket_main:
	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_right_bracket
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	jmp for_b_done

colon:
	# c: if ((line == 0x1 || line == 0x2 || line == 0x10 || line == 0x11) && ((col >= 0x1 && col <= 0xE) || (col >= start_sh))
	cmpl $0x1, %eax
	cmovnzl %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0x2, %eax
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi

	cmpl $0x10, %eax
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi

	cmpl $0x11, %eax
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi
	pushl %edi

	cmpl $0x1, %ebx
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $0xE, %ebx
	cmovg %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi
	pushl %edi

	cmpl $start_sh, %ebx
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	popl %esi
	orl %esi, %edi

	popl %esi
	andl %esi, %edi

	cmpl $0x1, %edi
	je colon_main_part

	# c: if ((line == 0x3 || line == 0xF) && ((col >= 0x1 && col <= 0x6) || col == 0xE || col == start_sh || (col >= start_sh + 8 && col <= size_x - 1)))
	cmpl $0x3, %eax
	cmovnzl %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0xF, %eax
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi
	pushl %edi

	cmpl $0x1, %ebx
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $0x6, %ebx
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi
	pushl %edi

	cmpl $start_sh + 8, %ebx
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $size_x - 1, %ebx
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi
	popl %esi
	orl %esi, %edi

	cmpl $0xE, %ebx
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi

	cmpl $start_sh, %ebx
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	orl %esi, %edi
	popl %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	je colon_main_part

	# c: if (line >= 0x4 && line <= 0xE && ((col >= 0x1 && col <= 0x5) || (col >= start_sh + 9 && col <= size_x - 1))) 
	cmpl $0x4, %eax
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $0xE, %eax
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi
	pushl %edi

	cmpl $0x1, %ebx
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $0x5, %ebx
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi
	pushl %edi

	cmpl $start_sh + 9, %ebx
	cmovll %ecx, %edi
	cmovgel %edx, %edi

	cmpl $size_x - 1, %ebx
	cmovgl %ecx, %esi
	cmovlel %edx, %esi

	andl %esi, %edi
	popl %esi
	orl %esi, %edi
	popl %esi
	andl %esi, %edi

	cmpl $0x1, %edi
	jne university

colon_main_part:
	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_colon
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	jmp for_b_done

university:
	# c: if (line == 0x7 && col == 0x15)
	cmpl $0x7, %eax
	cmovnzl %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0x15, %ebx
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	jne group

	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_university
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	addl $0x3, %ebx

	jmp for_b_done

group:
	# c: if (line == 0x8 && col == 0x14)
	cmpl $0x8, %eax
	cmovnzl %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0x14, %ebx
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	jne name

	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_group
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	addl $0x5, %ebx

	jmp for_b_done

name:
	# c: if (line == 0x9 && col == 0xA)
	cmpl $0x9, %eax
	cmovnzl %ecx, %edi
	cmovzl %edx, %edi

	cmpl $0xA, %ebx
	cmovnzl %ecx, %esi
	cmovzl %edx, %esi

	andl %esi, %edi

	cmpl $0x1, %edi
	jne big_else

	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_name
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	addl $0x19, %ebx

	jmp for_b_done

big_else:
	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_space
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

for_b_done:
	incl %ebx
	jmp for_b

for_b_end:
	# Saving registers
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	pushl $format_newline
	call printf
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax

	incl %eax
	xorl %ebx, %ebx
	jmp for_a

for_a_end:
	pushl stdout
	call fflush
	addl $0x4, %esp

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

# if_cond: #[optimized a bit version]
# cmp{b, w, l} ..., ...
# j{a, b, c, e, g, l, ...} else_branch # inverse condition

# then_branch:

# 	jmp end_if

# else_branch:

# end_if:

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
	xorl %eax, %eax
	xorl %ebx, %ebx

	# Main part
for_i:
	
for_j:

for_j_end:

for_i_end:

exit:
	# Exiting
	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

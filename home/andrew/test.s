.section .rodata
hello_str:
	.asciz "Hello!\n"
	.equ len_hello_str, . - hello_str

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	.equ str, -4                # char *
	subl $0x4, %esp

	# Initializing variables
	movl $hello_str, str(%ebp)

	# Main part
	movl $0x4, %eax             # write
	movl $0x1, %ebx             # fd
	movl str(%ebp), %ecx        # buf
	movl $len_hello_str, %edx   # nbytes
	int $0x80 # 0x80's interrupt

	# Exiting
	movl $0x1, %eax             # exit
	xorl %ebx, %ebx             # EXIT_SUCCESS
	int $0x80 # 0x80's interrupt

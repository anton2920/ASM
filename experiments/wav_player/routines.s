.equ STDOUT, 1
.equ STDIN, 0

.equ siezeof_int, 4
.equ first_param, 8
.equ second_param, first_param + siezeof_int
.equ third_param, second_param + siezeof_int

.section .bss 
.lcomm NUM_BUF, 500

.section .text
.globl write
.type write, @function
.equ SYS_WRITE, 4
.equ STDOUT, 1
write:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
    movl $SYS_WRITE, %eax # Write syscall
    movl first_param(%ebp), %ebx # File descriptor
    movl second_param(%ebp), %ecx # Buffer
    movl third_param(%ebp), %edx # Buffer size
    int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl read
.type read, @function
.equ SYS_READ, 3
.equ STDIN, 0
read:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
    movl $SYS_READ, %eax # Read syscall
    movl first_param(%ebp), %ebx # File descriptor
    movl second_param(%ebp), %ecx # Buffer
    movl third_param(%ebp), %edx # Buffer size
    int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl open
.type open, @function
.equ SYS_OPEN, 5
open:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Syscall
    movl $SYS_OPEN, %eax # Open syscall
    movl first_param(%ebp), %ebx # File name
    movl second_param(%ebp), %ecx # Mode
    movl third_param(%ebp), %edx # Permissions
    int $0x80 # 0x80's interrupt

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl close
.type close, @function
.equ SYS_CLOSE, 6
close:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Syscall
    movl $SYS_CLOSE, %eax # Close syscall
    movl first_param(%ebp), %ebx # File descriptor
    int $0x80 # 0x80's interrupt

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl ioctl
.type ioctl, @function
.equ SYS_IOCTL, 54
ioctl:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Syscall
	movl $SYS_IOCTL, %eax
	movl first_param(%ebp), %ebx
	movl second_param(%ebp), %ecx
	movl third_param(%ebp), %edx
	int $0x80 # 0x80's interrupt

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl lstrlen
.type lstrlen, @function
lstrlen:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl first_param(%ebp), %ebx # Saving pointer to beginning of the string 
	movl %ebx, %eax

	# Main part
nextchar:
	cmpb $0x0, (%eax) # Comparing '\0' with beginning of the string
	jz finished # If true, go to «finished» label, ending loop

	incl %eax # Increasing %eax by 1
	jmp nextchar

finished:
	subl %ebx, %eax # Subtracting %ebx from %eax; result — length of the string

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl lputchar
.type lputchar, @function
lputchar:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# I/O flow
	leal 8(%ebp), %eax
	movl $0x1, %ebx

	pushl %ebx 
	pushl %eax # &a
	pushl $STDOUT
	call write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret
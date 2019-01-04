# Macros
.equ SYS_READ, 3
.equ SYS_WRITE, 4
.equ SYS_OPEN, 5
.equ SYS_CLOSE, 6
.equ OK_STATE, 0
.equ ERROR_STATE, -1

.section .data

#.section .bss
#    .equ BUFFER_SIZE, 2048
#    .lcomm BUFFER_DATA, BUFFER_SIZE

.section .text
.globl awrite
awrite:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Syscall
    movl $SYS_WRITE, %eax # Write syscall
    movl 8(%ebp), %ebx # File descriptor
    movl 12(%ebp), %ecx # Buffer
    movl 16(%ebp), %edx # Buffer size
    int $0x80 # 0x80's interrupt

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl aread
aread:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Syscall
    movl $SYS_READ, %eax # Read syscall
    movl 8(%ebp), %ebx # File descriptor
    movl 12(%ebp), %ecx # Buffer
    movl 16(%ebp), %edx # Buffer size
    int $0x80 # 0x80's interrupt

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl aopen
aopen:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Syscall
    movl $SYS_OPEN, %eax # Open syscall
    movl 8(%ebp), %ebx # File name
    movl 12(%ebp), %ecx # Mode
    movl 16(%ebp), %edx # Permissions
    int $0x80 # 0x80's interrupt

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl aclose
aclose:
    # Initialzing function's stack frame
    pushl %ebp
    movl %esp, %ebp

    # Syscall
    movl $SYS_CLOSE, %eax # Close syscall
    movl 8(%ebp), %ebx # File descriptor
    int $0x80 # 0x80's interrupt

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

#.globl make_file_name
#make_file_name:
#    # Initializing function's stack frame
#    pushl %ebp
#    movl %esp, %ebp
#
#    # Initializing variables
#    subl $0x4, %esp # Acquires -4(%ebp) for smth
#
#    # Main part
#    movl 8(%ebp), %eax # namep
#    movb $0x0, %bl # current letter (curr)
#    movl 12(%ebp), %ecx # len
#    decl %eax # --namep
#    incl %ebx # ++len
#
#make_name_loop:
#    incl %eax # ++namep
#    movb (%eax), %bl # curr = *name
#    decl %ecx # --len
#    cmpl $0x0, %ecx # if (len == 0)
#    je end_make_name_loop # break
#
#    cmpb $0xA, %bl # if (curr != '\n')
#    jne make_name_loop # continue
#
#    movl $0x0, (%eax) # *name = '\0'
#
#end_make_name_loop:
#    # Destroying function's stack frame
#    movl %ebp, %esp
#    popl %ebp
#    ret

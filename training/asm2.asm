.globl sum
.globl agetchar

.section .data
num:
    .long 0x0

.section .text
sum:
    movl %edi, %eax
    addl %esi, %eax
    ret

agetchar:
    movl $0x3, %eax
    movl $0x0, %ebx
    leal num, %ecx
    movl $1024, %edx
    int $0x80

    movl (num), %eax
    subl $2560, %eax
    ret

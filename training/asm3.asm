.section .data

.section .text
.globl power
power:
    pushl %ebp
    movl %esp, %ebp

    movl 12(%ebp), %eax
    movl 8(%ebp), %ebx
    pushl %eax
    pushl %ebx
    call lpow

    movl %ebp, %esp
    popl %ebp
    ret

.type lpow, @function
# 12(%ebp) — power
# 8(%ebp) — base
lpow:
    pushl %ebp
    movl %esp, %ebp
    subl $4, %esp # Acquires -4(%ebp) as a local variable for current result
    movl 8(%ebp), %ebx # base
    movl 12(%ebp), %ecx # power

    # check, if power == 0
    movl $0x1, -4(%ebp) # current = 1
    cmpl $0x0, %ecx
    je end_lpow

    # general case
    movl %ebx, -4(%ebp) # current = %ebx = base
pow_start_loop:
    cmpl $0x1, %ecx
    je end_lpow

    movl -4(%ebp), %eax
    imul %ebx, %eax
    movl %eax, -4(%ebp)
    decl %ecx
    jmp pow_start_loop

    # final things
end_lpow:
    movl -4(%ebp), %eax
    movl %ebp, %esp
    popl %ebp
    ret

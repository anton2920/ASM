.section .rodata
array: 
    .int 2, 4, 0, 100, 4, 11, 2602, 36
    .equ array_len, . - array

array2: 
    .int 160, 3, 1719, 19, 11, 13, -21
    .equ array2_len, . - array2

# ENUM
# STATE_UNDEF = 0
# STATE_EVEN = 1
# STATE_ODD = 2

.section .text
.globl _start
_start: 
    # Initializing stack frame
    movl %esp, %ebp
    .equ last_even, -0x4    # int
    .equ last_odd, -0x8     # int
    .equ even_cnt, -0xC     # int
    .equ odd_cnt, -0x10     # int
    subl $0x10, %esp

    # Initializing variables
    movl $0x0, last_even(%ebp)
    movl $0x0, last_odd(%ebp)
    movl $0x0, even_cnt(%ebp)
    movl $0x0, odd_cnt(%ebp)

    movl $array2_len, %edx
    shrl $0x2, %edx

    xorl %eax, %eax # STATE_UNDEF
    xorl %ecx, %ecx

_start_for_loop: 
    cmpl %edx, %ecx
    je _start_for_loop_end

# _start_for_loop_if:
    movl array2(, %ecx, 4), %ebx
    testl $0x1, %ebx
    jnz _start_for_loop_else

# _start_for_loop_then:
    movl $last_even, %esi
    movl $even_cnt, %edi

    jmp _start_for_loop_endif

_start_for_loop_else: 
    movl $last_odd, %esi
    movl $odd_cnt, %edi

_start_for_loop_endif: 
    movl %ebx, (%ebp, %esi)
    incl (%ebp, %edi)

    testl %eax, %eax
    jnz _start_for_loop_footer

    # Setting state
    negl %esi
    shrl $0x2, %esi

    movl (%ebp, %edi), %ebx
    cmpl $0x2, %ebx
    cmovel %esi, %eax

_start_for_loop_footer: 
    incl %ecx
    jmp _start_for_loop

_start_for_loop_end: 

_start_exit: 
    xorb $0b11, %al # Swapping 1 <--> 2
    negl %eax # Making it a proper index

    movl (%ebp, %eax, 4), %ebx
    movl $0x1, %eax
    int $0x80 # 0x80's interrupt

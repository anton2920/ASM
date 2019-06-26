.text
.globl main
main:
	xor %ecx,  %ecx
	mov $32,   %edx    ;//Depth
	mov $600,  %esi    ;//Height
	mov $800,  %edi    ;//Width
	call SDL_SetVideoMode
	mov %rax,     %r12  ;// Save surface to %r12
	mov 32(%rax), %rbx ;// Save pointer to pixels
	lea .L8(%rip), %r14
	fninit
    fild    .L6(%rip)
    fld1
    fld     %st(0)
    fdiv    %st,%st(2)
    mov	$600,%r13  ;//Height
.L5:    fld     %st(1)  ;// Vertical loop
    mov     $800,%ecx ;//Width
.L4:    fld     %st(1)  ;// Horizontal loop
    fld     %st(1)
    mov     $4, %ax ;// Limit for test whether it escaped
    xor	%edx, %edx
.L2:    fld     %st(1)
    fmul    %st,%st(2)
    fld     %st(1)
    fmul    %st,%st(2)
    fmulp   %st,%st(1)
    fld     %st(2)
    fadd    %st(2),%st
    fistp   (%r14)
    fadd    %st,%st(0)
    fadd    %st(4),%st
    fxch    %st(2)
    fsubrp  %st(1)
    cmp     %ax, (%r14)
    jnbe    .L1
    fadd    %st(2),%st
    inc	%dl
    jnz     .L2
.L1:    imul	$0x030507, %edx, %edx
    mov	%edx, (%rbx)
    add	$4, %rbx
    fstp    %st(0)
    fstp    %st(0)
    fsub    %st(3),%st
    loop    .L4       ;// Horizontal loop
    fstp    %st(0)
    fsub    %st(2),%st

    mov	%r12, %rdi
    call	SDL_Flip

    dec	%r13
    jnz	.L5	;// Vertical loop
    
.L9:    lea .Lev(%rip), %rdi
    call SDL_WaitEvent
    cmpb $2, .Lev(%rip)
    jne .L9
    ret

.L6:	.word 312

.lcomm .L8,  2
.lcomm .Lev,24

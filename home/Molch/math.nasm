GLOBAL summirovaniye
GLOBAL summirovaniye:function
summirovaniye: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; Initializing variables
        mov  eax, [ebp+8]  ; a
        mov  ebx, [ebp+12]  ; b

        ; Main part
        add  eax,ebx    ; a = a + b

        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL vichitaniye
GLOBAL vichitaniye:function
vichitaniye: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; Initializing variables
        mov  eax, [ebp+8]  ; a
        mov  ebx, [ebp+12]  ; b

        ; Main part
        sub  eax,ebx    ; a = a - b

        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL umnogeniye
GLOBAL umnogeniye:function
umnogeniye: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; Initializing variables
        mov  eax, [ebp+8]  ; a
        mov  ebx, [ebp+12]  ; b

        ; Main part
        imul  eax,ebx    ; a = a * b

        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL deleniye
GLOBAL deleniye:function
deleniye: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; Initializing variables
        mov  esi, [ebp+8]  ; s = &a
        mov  ebx, [ebp+12]  ; b
        xor  edx,edx

        ; Main part
        cmp  ebx,00h
        je deleniye_wrong

        mov  eax, [esi]
        idiv  dword [ebx]
        mov  [ebx],edx

        jmp deleniye_exit

deleniye_wrong: 
        mov  eax,-1

deleniye_exit: 
        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL power
GLOBAL power:function
power: 
        ; Initializing function's stack frame
    push  ebp
    mov  ebp,esp
    sub  esp,4    ; Acquiring space in -4(%ebp)

    ; Initializing variables
    mov  ebx, [ebp+8]  ; base
    mov  ecx, [ebp+12]  ; power

    ; Main part
    mov  dword [ebp-4],01h ; current = 1
    cmp  ecx,00h    ; if (power == 0)
    je end_lpow

    mov  [ebp-4],ebx    ; current = %ebx = base

pow_start_loop: 
    cmp  ecx,01h
    je end_lpow

    mov  eax, [ebp-4]
    imul eax, ebx
    mov  [ebp-4],eax
    dec  ecx
    jmp pow_start_loop

end_lpow: 
        ; Destroying function's stack frame
    mov  eax, [ebp-4]
    mov  esp,ebp
    pop  ebp
    ret


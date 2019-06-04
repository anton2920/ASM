SECTION  .bss
NUM_BUF resb 500

SECTION  .text
GLOBAL write
GLOBAL write:function
SYS_WRITE equ 4
STDOUT equ 1
write: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; I/O flow
        mov  eax, SYS_WRITE
        mov  ebx, STDOUT
        mov  ecx, [ebp+8]
        mov  edx, [ebp+12]
        int 080h  ; 0x80's interrupt

        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL atoi
GLOBAL atoi:function
atoi: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp
        sign equ -4
        sub  esp,04h    ; Acquiring space in sign(%ebp) — minus sign

        ; Initializing variables
        req_str equ 8
        mov  ebx, [req_str+ebp]
        xor  ecx,ecx    ; offset
        xor  eax,eax    ; res
        mov  dword [sign+ebp],01h

        ; Main part
atoi_if: 
        xor  edx,edx
        mov  dl, [ebx]
        cmp  dl, '-'   ; if (d == '-')
        jne atoi_if_2

atoi_then: 
        mov  dword [sign+ebp],-1 ; sign = 
        inc  ecx
        jmp atoi_main_loop

atoi_if_2: 
        cmp  dl, '+'   ; if (d == '+')
        jne atoi_main_loop

atoi_then_2: 
        mov  dword [sign+ebp],01h
        inc  ecx

atoi_main_loop: 
        xor  edx,edx
        mov  dl, [ebx+ecx*1]
        cmp  dl,00h
        je atoi_main_loop_end

        sub  dl, '0'
        imul  eax,0Ah
        add  eax,edx

        inc  ecx

        jmp atoi_main_loop

atoi_main_loop_end: 
        mov  edx, [sign+ebp]
        imul  eax,edx

        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL iprint
GLOBAL iprint:function
iprint: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; Initializing variables
        mov  eax, [ebp+8]  ; Number

        ; Main part
iprint_if: 
        cmp  eax,00h    ; if (a > 0)
        jg iprint_else

iprint_then: 
        cmp  eax,00h
        je iprint_print_0

        push  eax
        mov  edx, '-'
        push  edx
        call putchar
        add  esp,04h
        pop  eax

        imul  eax,-1

iprint_else: 
        push  eax

        push  eax
        call numlen
        add  esp,04h

        pop  ebx
        push  eax

        push  eax
        push  ebx
        call reverse
        add  esp,08h

        pop  eax
        imul  eax,04h
        push  eax
        push  dword NUM_BUF
        call write
        add  esp,08h
        jmp iprint_fin

iprint_print_0: 
        mov  edx, '0'
        push  edx
        call putchar
        add  esp,04h

iprint_fin: 
        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL reverse:function  ; int and char *
reverse: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; Initializing variables
        mov  eax, [ebp+8]  ; Number
        mov  ebx, [ebp+12]  ; Position
        dec  ebx
        mov  ecx,0Ah
        mov  edi, NUM_BUF

        ; Main part
reverse_main_loop: 
        cmp  ebx,00h
        jl reverse_main_loop_end

        xor  edx,edx
        idiv  ecx

        add  edx, '0'
        mov  [edi+ebx*4],edx
        dec  ebx

        jmp reverse_main_loop

reverse_main_loop_end: 
        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL putchar
GLOBAL putchar:function
putchar: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; I/O flow
        lea  eax, [ebp+8]
        mov  ebx,01h

        push  ebx
        push  eax  ; &a
        call write
        add  esp,08h

        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret

GLOBAL numlen:function
numlen: 
        ; Initializing function's stack frame
        push  ebp
        mov  ebp,esp

        ; Main part
        mov  eax, [ebp+8]  ; Number
        xor  ebx,ebx    ; Len
        mov  ecx,0Ah

numlen_loop: 
        cmp  eax,00h
        je numlen_loop_end

        xor  edx,edx
        idiv  ecx

        inc  ebx

        jmp numlen_loop

numlen_loop_end: 
        mov  eax,ebx

        ; Destroying function's stack frame
        mov  esp,ebp
        pop  ebp
        ret


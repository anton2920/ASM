extern printf, scanf

SECTION  .rodata
format_output: 
        db     "Welcome to assemply floating-point", 0Ah, "   value's function tabulator!", 0Ah, 0Ah, 0h
format_table: 
        db     "|", 09h, "%.1lf", 09h, "|", 09h, "%lf", 09h, "|", 0Ah, 0h
format_table_head: 
        db     "|", 09h, "x", 09h, "|", 09h, "   f(x)", 09h, 09h, "|", 0Ah, 0h
format_function: 
        db     0Ah, "f(x) = sin(x) + cos(x / 2) * x", 0Ah, 0Ah, 0
format_line: 
        db     " ----------------------------------------", 0Ah, 0

SECTION  .data
VAR_X: 
        dq -1.0
increment: 
        dq 0.1
int_2: 
        dd    2

SECTION  .text
GLOBAL _start
_start: 
        ; Initializing stack frame
        mov  ebp,esp

        ; I/O flow
        push  dword format_output
        call printf
        add  esp,04h

        push  dword format_function
        call printf
        add  esp,04h

        push  dword format_line
        call printf
        add  esp,04h

        push  dword format_table_head
        call printf
        add  esp,04h

        push  dword format_line
        call printf
        add  esp,04h

        ; Main part. FPU
        finit
        fld  qword [VAR_X]

do_while_loop: 

        ; cos(x / 2)
        fld st0
        fidiv dword [int_2]
        fcos

        ; cos (x / 2) * x
        fld st1
        fmulp st1, st0

        ; sin(x)
        fld st1
        fsin

        ; sin(x) + cos(x / 2) * x
        faddp st1, st0

        ; Printing
        sub  esp,08h
        fstp  qword [esp]

        sub  esp,08h
        fst  qword [esp]

        push  dword format_table
        call printf
        add  esp,014h

        push  dword format_line
        call printf
        add  esp,04h

        fld1
        fcomip st1
        jc exit

        fadd  qword [increment]

        jmp do_while_loop

do_while_end: 
exit: 
        ; Exiting
        xor  eax,eax
        inc  eax
        xor  ebx,ebx
        int 080h  ; 0x80's interrupt

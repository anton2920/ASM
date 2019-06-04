%include "math.nasm"
%include "routines.nasm"

SECTION  .data
newline: 
        db     0Ah, 0h
len_newline: equ $ - newline
separator: 
        db     "––––––––––––––––––––––––––––––––––––––", 0Ah, 0h
len_separator: equ $ - separator
error_line: 
        db     "Error! Usage: <int> <sign> <int>", 0Ah, 0h
len_error_line: equ $ - error_line
space: 
        db     " ", 0h
len_space: equ $ - space
equals: 
        db     " = ", 0h
len_equals: equ $ - equals
remainder: 
        db     ", remainder = ", 0h
len_remainder: equ $ - remainder

SECTION  .text
GLOBAL _start
_start: 
        ; Initializing stack frame
        mov  ebp,esp
        first_num equ -8
        second_num equ -4
        sub  esp,08h    ; Acquiring space for two variables

        ; Initializing variables
        ARGC equ 0
        ARGV_1 equ 8
        ARGV_2 equ 12

        mov  ecx, [ARGC+ebp]
        dec  ecx
        lea  eax, [ARGV_1+ebp]

        ; Main part
        cmp  ecx,03h
        jne error

        ; VarCheck
        xor  ecx,ecx
        mov  ebx, [ARGV_2+ebp]
        mov  cl, [ebx]

        cmp  cl, '+'
        je first_number

        cmp  cl, '-'
        je first_number

        cmp  cl, '*'
        je first_number

        cmp  cl, '/'
        je first_number

        cmp  cl, '^'
        je first_number
        jne error

first_number: 
        ; Saving registers
        push  eax

        push  dword len_separator
        push  dword separator
        call write
        add  esp,08h

        ; Restoring registers
        pop  eax

        ; Saving registers
        push  eax

        push  dword [eax]
        call atoi
        add  esp,04h

        mov  [first_num+ebp],eax

        push  eax
        call iprint
        add  esp,04h

        push  dword len_space
        push  dword space
        call write
        add  esp,08h

        ; Restoring registers
        pop  eax

detect_sign: 
        add  eax,04h

        xor  ecx,ecx
        mov  ebx, [eax]
        mov  cl, [ebx]

        push  ecx  ; sign

        ; Saving registers
        push  eax

        push  ecx
        call putchar
        add  esp,04h

        push  dword len_space
        push  dword space
        call write
        add  esp,08h

        ; Restoring registers
        pop  eax

second_number: 
        add  eax,04h

        push  dword [eax]
        call atoi
        add  esp,04h

        mov  [second_num+ebp],eax

        push  eax
        call iprint
        add  esp,04h

        push  dword len_equals
        push  dword equals
        call write
        add  esp,08h

switch_case: 
        pop  ecx
        cmp  cl, '+'
        je plus_sign

        cmp  cl, '-'
        je minus_sign

        cmp  cl, '*'
        je mul_sign

        cmp  cl, '/'
        je div_sign

        cmp  cl, '^'
        je power_sign

        jmp default_case

plus_sign: 
        call summirovaniye
        add  esp,08h

        push  eax
        call iprint
        add  esp,04h

        jmp end_switch

minus_sign: 
        call vichitaniye
        add  esp,08h

        push  eax
        call iprint
        add  esp,04h

        jmp end_switch

mul_sign: 
        call umnogeniye
        add  esp,08h

        push  eax
        call iprint
        add  esp,04h

        jmp end_switch

div_sign: 
        lea  eax, [first_num+ebp]
        lea  ebx, [second_num+ebp]
        push  ebx
        push  eax
        call deleniye
        add  esp,08h

        push  eax
        call iprint
        add  esp,04h

        push  dword len_remainder
        push  dword remainder
        call write
        add  esp,08h

        mov  eax, [second_num+ebp]
        push  eax
        call iprint
        add  esp,04h

        jmp end_switch

power_sign: 
        call power
        add  esp,08h

        push  eax
        call iprint
        add  esp,04h

        jmp end_switch

default_case: 
        jmp error

end_switch: 
        push  dword len_newline
        push  dword newline
        call write
        add  esp,08h

        push  dword len_separator
        push  dword separator
        call write
        add  esp,08h

        jmp exit

error: 
        push  dword len_error_line
        push  dword error_line
        call write
        add  esp,08h

exit: 
        ; Exitting
        mov  eax,01h
        xor  ebx,ebx
        int 080h  ; 0x80's interrupt



section .rodata
array:
	dd	2, 4, 0, 100, 4, 11, 2602, 36
array_len: equ $ - array

array2:
	dd 160, 3, 1719, 19, 11, 13, -21
array2_len: equ $ - array2

; ENUM
; STATE_UNDEF = 0
; STATE_EVEN = 1
; STATE_ODD = 2

section .text
global _start
_start:
	; Initializing stack frame
	mov ebp, esp
	last_even equ -04h		; int
	last_odd equ -08h		; int
	even_cnt equ -0Ch		; int
	odd_cnt equ -10h		; int
	sub esp, 10h

	; Initializing variables
	mov DWORD [ebp + last_even], 00h
	mov DWORD [ebp + last_odd], 00h
	mov DWORD [ebp + even_cnt], 00h
	mov DWORD [ebp + odd_cnt], 00h

	mov edx, array2_len
	shr edx, 02h

	xor eax, eax ; STATE_UNDEF
	xor ecx, ecx

_start_for_loop:
	cmp ecx, edx
	je _start_for_loop_end

; _start_for_loop_if:
	mov ebx, DWORD [array2 + ecx * 4]
	test ebx, 01h
	jnz _start_for_loop_else

; _start_for_loop_then:
	mov esi, last_even
	mov edi, even_cnt

	jmp _start_for_loop_endif

_start_for_loop_else:
	mov esi, last_odd
	mov edi, odd_cnt

_start_for_loop_endif:
	mov DWORD [ebp + esi], ebx
	inc DWORD [ebp + edi]

	test eax, eax
	jnz _start_for_loop_footer

    ; Setting state
    neg esi
    shr esi, 02h

	mov ebx, [ebp + edi]
	cmp ebx, 02h
	cmove eax, esi

_start_for_loop_footer:
	inc ecx
	jmp _start_for_loop

_start_for_loop_end:

_start_exit:
	xor al, 11b
	neg eax

	mov ebx, DWORD [ebp + eax * 4]
	mov eax, 01h
	int 80h ; 0x80's interrupt

extern printf
extern scanf

section .data
format_input:
	db '%d', 0h
format_answer:
	db 'Answer (%d, %d): %d', 0Ah, 0h

section .text
GLOBAL _start
_start:
	; Initializing stack frame
	mov ebp, esp
	sub esp, 4 ; Acquiring space in -4(%ebp)

	; I/O flow
	lea eax, [ebp - 4]
	push eax
	push dword format_input
	call scanf
	add esp, 8
	mov eax, [ebp - 4]
	push eax

	lea ebx, [ebp - 4]
	push ebx
	push dword format_input
	call scanf
	add esp, 8
	mov ebx, [ebp - 4]

	; Main part
	pop eax
if:
	cmp eax, ebx
	jge else
	cmp ebx, 0h
	je else

then:
	mov ecx, 5
	jmp end_if

else:
	mov ecx, 6

end_if:
	; Final output
	push ecx
	push ebx
	push eax
	push format_answer
	call printf
	add esp, 8

exit:
	; Exiting
	xor eax, eax
	inc eax
	xor ebx, ebx
	int 080h ; 0x80's interrupt

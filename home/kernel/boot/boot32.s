.code32

.globl _start_protected_mode
.type _start_protected_mode, @function
_start_protected_mode:
	leal booted_prot_str, %edi
	calll prints_s

	jmp .

booted_prot_str:
	.asciz "done. Now in Intel's protected mode."

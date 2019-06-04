.section .data
msg:
	.asciz "Hello NASM\n"

.section .text
.globl _start
_start:
	# write(1, msg, 11)
	movl $0x4, %eax # номер системного вызова
	movl $0x1, %ebx # дескриптор файла, куда выводим
	movl $msg, %ecx # адрес того, что выводим
	movl $0xB, %edx # сколько байт выводим

	int $0x80 # совершаем 80-е прерывание (системный вызов)

	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80

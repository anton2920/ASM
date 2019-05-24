.section .data #глобальная переменная
msg:
	.asciz "Hello GAS, GNU's assembler\n"#название,объявления байтов,сам текст ,\n

.section .text #секциия в которой идёт код программы НАШЕЙ
.globl _start #для того ,чтобы запустить 
_start: #начинается функция
	movl %esp, %ebp #инструкция,которая перемещает откуда-то куда-то (mov)
	movl $msg, %ebx
	movl %ebx, %eax
	
nextchar:
	# cmp ... # if (*eax ? 0)
	xorl %ecx, %ecx
	movb %al, %cl
	cmpb $0x0, %cl #инструкция сравнения (cmp) 
	je finished # je # ? = '=='

	incl %eax # ++eax
	jmp nextchar # goto nextchar

finished:
	subl %ebx, %eax #инструкция для вычитания (sub)

	movl %eax, %edx
	movl $msg, %ecx
	movl $0x1, %ebx
	movl $0x4, %eax

	int $0x80

	xorl %eax, %eax
	incl %eax
	xorl %ebx, %ebx
	int $0x80

# "Hello" = { 'H', 'e', 'l', 'l', 'o', '\0'}
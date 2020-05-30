.include "constants.s"

.section .rodata
error_no_port:
	.asciz "server: no port provided\n"
.equ len_error_no_port, . - error_no_port

error_port_out:
	.asciz "server: port is out of range\n"
.equ len_error_port_out, . - error_port_out

error_socket:
	.asciz "server: can't open socket\n"
.equ len_error_socket, . - error_socket

error_bind:
	.asciz "server: can't bind the socket to the address\n"
.equ len_error_bind, . - error_bind

error_accept:
	.asciz "server: can't accept a connection\n"
.equ len_error_accept, . - error_accept

error_read:
	.asciz "server: can't read client's message\n"
.equ len_error_read, . - error_read

error_write:
	.asciz "server: can't write to the socket\n"
.equ len_error_write, . - error_write

write_msg:
	.asciz "server: your message is "
.equ len_write_msg, . - write_msg

.section .data
var_n:
	.long 0

.section .bss
.equ sizeof_buffer, 1024
.lcomm buffer, sizeof_buffer

.lcomm serv_addr, sizeof_sockaddr_in	# static struct sockaddr_in (0x10 bytes)
.lcomm cli_addr, sizeof_sockaddr_in		# static struct sockaddr_in (0x10 bytes)

.section .text
.globl _start
_start:
	# Initializing stack frame
	movl %esp, %ebp
	subl $0x10, %esp
	.equ sockfd, -sizeof_int				# auto int (0x4 bytes)
	.equ newsockfd, sockfd - sizeof_int		# auto int (0x4 bytes)
	.equ portno, newsockfd - sizeof_int		# auto int (0x4 bytes)
	.equ clilen, portno - sizeof_int		# auto unsigned int (0x4 bytes)

	# VarCheck
	cmpl $0x2, (%ebp)
	je start_check_ok

	pushl $len_error_no_port
	pushl $error_no_port
	pushl $STDERR
	calll write
	addl $0xC, %esp

	jmp exit

start_check_ok:
	# Main part
	pushl 8(%ebp)
	calll atoi
	addl $0x4, %esp

	cmpl $0xFFFF, %eax
	jle port_check_ok

	pushl $len_error_port_out
	pushl $error_port_out
	pushl $STDERR
	calll write
	addl $0xC, %esp

	jmp exit

port_check_ok:
	movl %eax, portno(%ebp) # Saving port number

	# Socket call
	pushl $PROTOCOL
	pushl $SOCK_STREAM
	pushl $AF_INET
	calll socket
	addl $0xC, %esp

	cmpl $0x0, %eax
	jge socket_check_ok

	pushl $len_error_socket
	pushl $error_socket
	pushl $STDERR
	calll write
	addl $0xC, %esp

	jmp exit

socket_check_ok:
	movl %eax, sockfd(%ebp)

	movl $AF_INET, serv_addr + sockaddr_in_sin_family
	movl $INADDR_ANY, serv_addr + sockaddr_in_sin_addr

	pushl portno(%ebp)
	call htons
	addl $0x4, %esp

	movl %eax, serv_addr + sockaddr_in_sin_port

	pushl $sizeof_sockaddr_in
	pushl $serv_addr
	pushl sockfd(%ebp)
	calll bind
	addl $0xC, %esp

	cmpl $0x0, %eax
	jge bind_check_ok

	pushl $len_error_bind
	pushl $error_bind
	pushl $STDERR
	calll write
	addl $0xC, %esp

	jmp exit

bind_check_ok:
	.equ BACKLOG, 0x5
	pushl $BACKLOG
	pushl sockfd(%ebp)
	calll listen
	addl $0x8, %esp

	movl $sizeof_sockaddr_in, clilen(%ebp)

	leal clilen(%ebp), %eax
	pushl %eax
	pushl $cli_addr
	pushl sockfd(%ebp)
	calll accept
	addl $0xC, %esp

	cmpl $0x0, %eax
	jge accept_check_ok

	pushl $len_error_accept
	pushl $error_accept
	pushl $STDERR
	calll write
	addl $0xC, %esp

	jmp exit

accept_check_ok:
	movl %eax, newsockfd(%ebp)

	pushl $sizeof_buffer
	pushl $buffer
	pushl newsockfd(%ebp)
	calll read
	addl $0xC, %esp

	cmpl $0x0, %eax
	jge read_check_ok

	pushl $len_error_read
	pushl $error_read
	pushl $STDERR
	calll write
	addl $0xC, %esp

	jmp exit

read_check_ok:
	movl %eax, var_n

	pushl $len_write_msg
	pushl $write_msg
	pushl newsockfd(%ebp)
	calll write
	addl $0xC, %esp

	cmpl $0x0, %eax
	jl write_check_fail

	pushl var_n
	pushl $buffer
	pushl newsockfd(%ebp)
	calll write
	addl $0xC, %esp

	cmpl $0x0, %eax
	jge exit

write_check_fail:
	pushl $len_error_write
	pushl $error_write
	pushl $STDERR
	calll write
	addl $0xC, %esp

exit:
	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

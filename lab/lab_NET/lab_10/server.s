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

entry_message:
	.asciz "┌─────────────────────────────────────────────────────────────┐\n"
	.asciz "│ <=== Welcome to the Tushino Datacenter Advanced Server ===> │\n"
	.asciz "├─────────────────────────────────────────────────────────────┤\n"
	.asciz "│ Type \"help\" to list all commands                            │\n"
	.asciz "└─────────────────────────────────────────────────────────────┘\n\n"
.equ len_entry_message, . - entry_message

prompt:
	.asciz "tushino$> "
.equ len_prompt, . - prompt

command_help:
	.asciz "help"
.equ len_command_help, . - command_help

command_help_result:
	.asciz "┌───────────┬───────────────────────────────────────────────┐\n"
	.asciz "│  Command  │                  Description                  │\n"
	.asciz "├───────────┼───────────────────────────────────────────────┤\n"
	.asciz "│ creat     │ Creates file with a given name                │\n"
	.asciz "├───────────┼───────────────────────────────────────────────┤\n"
	.asciz "│ info      │ Prints information about creator              │\n"
	.asciz "├───────────┼───────────────────────────────────────────────┤\n"
	.asciz "│ help      │ Prints detailed info about existing commands  │\n"
	.asciz "├───────────┼───────────────────────────────────────────────┤\n"
	.asciz "│ shutdown  │ Shuts the server down                         │\n"
	.asciz "├───────────┼───────────────────────────────────────────────┤\n"
	.asciz "│ task      │ Prints information about server's destiny     │\n"
	.asciz "├───────────┼───────────────────────────────────────────────┤\n"
	.asciz "│ time      │ Prints server local time                      │\n"
	.asciz "├───────────┼───────────────────────────────────────────────┤\n"
	.asciz "│ quit      │ Closes connection with server                 │\n"
	.asciz "└───────────┴───────────────────────────────────────────────┘\n"
.equ len_command_help_result, . - command_help_result

command_info:
	.asciz "info"
.equ len_command_info, . - command_info

command_info_result:
	.asciz "© Pavlovsky Anton, 2020"
.equ len_command_info_result, . - command_info_result

command_time:
	.asciz "time"
.equ len_command_time, . - command_time

command_time_result:
	.asciz "Server time: "
.equ len_command_time_result, . - command_time_result

command_task:
	.asciz "task"
.equ len_command_task, . - command_task

command_task_result:
	.asciz "┌──────────────────────────────────────────────────────────┐\n"
	.asciz "│                         Task #15                         │\n"
	.asciz "├──────────────────────────────────────────────────────────┤\n"
	.asciz "│ Add to the server's services support for an additional   │\n"
	.asciz "│ command for creating a file on the server                │\n"
	.asciz "├──────────────────────────────────────────────────────────┤\n"
	.asciz "│ - Input parameter: name of the file                      │\n"
	.asciz "│ - Server response: command's status                      │\n"
	.asciz "└──────────────────────────────────────────────────────────┘\n"
.equ len_command_task_result, . - command_task_result

command_creat:
	.asciz "creat"
.equ len_command_creat, . - command_creat

command_quit:
	.asciz "quit"
.equ len_command_creat, . - command_creat

command_quit_result:
	.asciz "Bye!\n"
.equ len_command_quit_result, . - command_quit_result

command_shutdown:
	.asciz "shutdown"
.equ len_command_shutdown, . - command_shutdown

command_shutdown_result:
	.asciz "Server is shutting down...\n"
.equ len_command_shutdown_result, . - command_shutdown_result

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

while_not_shutdown:
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

	pushl $len_entry_message
	pushl $entry_message
	pushl newsockfd(%ebp)
	calll write
	addl $0xC, %esp

	cmpl $0x0, %eax
	jge write_entry_check_ok

	pushl $len_error_write
	pushl $error_write
	pushl $STDERR
	calll write
	addl $0xC, %esp

write_entry_check_ok:
	pushl newsockfd(%ebp)
	calll performator
	addl $0x4, %esp

	testl %eax, %eax
	jnz while_not_shutdown

	pushl newsockfd(%ebp)
	calll closesocket
	addl $0x4, %esp

while_not_shutdown_end:
	pushl sockfd(%ebp)
	calll closesocket
	addl $0x4, %esp

exit:
	# Exitting
	movl $0x1, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

.type performator, @function
.equ SHUTDOWN_COMMAND, 0
.equ QUIT_COMMAND, 1
performator:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
while_true:
	pushl $len_prompt
	pushl $prompt
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	pushl $sizeof_buffer
	pushl $buffer
	pushl first_arg(%ebp)
	calll read
	addl $0xC, %esp

	movb $0x0, buffer - 1(%eax)

	movl %eax, var_n

	pushl $buffer
	pushl $command_help
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz help_check_fail

	pushl $len_command_help_result
	pushl $command_help_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	jmp while_true

help_check_fail:
	pushl $buffer
	pushl $command_quit
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz quit_check_fail

	pushl $len_command_quit_result
	pushl $command_quit_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	movl $QUIT_COMMAND, %eax

	jmp while_true_end

quit_check_fail:
	pushl $buffer
	pushl $command_shutdown
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz shutdown_check_fail

	pushl $len_command_shutdown_result
	pushl $command_shutdown_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	movl $SHUTDOWN_COMMAND, %eax

	jmp while_true_end

shutdown_check_fail:
	pushl $buffer
	pushl $command_info
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz info_check_fail

	pushl $len_command_info_result
	pushl $command_info_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	jmp while_true

info_check_fail:
	pushl $buffer
	pushl $command_task
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz task_check_fail

	pushl $len_command_task_result
	pushl $command_task_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	jmp while_true

task_check_fail:
	jmp while_true

while_true_end:

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type closesocket, @function
closesocket:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	subl $0x4, %esp # Acquiring space for one variable

	# Initializing variables
	movl $0x1, -4(%ebp)

	# Main part
	# pushl $SHUT_WR
	# pushl first_arg(%ebp)
	# calll shutdown
	# addl $0x8, %esp

	pushl $sizeof_int
	leal -4(%ebp), %eax
	pushl %eax
	pushl $SO_REUSEADDR
	pushl $SOL_SOCKET
	pushl first_arg(%ebp)
	calll setsockopt
	addl $0x14, %esp

	# pushl sockfd(%ebp)
	# calll close
	# addl $0x4, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

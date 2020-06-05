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
	.ascii "┌─────────────────────────────────────────────────────────────┐\n"
	.ascii "│ <=== Welcome to the Tushino Datacenter Advanced Server ===> │\n"
	.ascii "├─────────────────────────────────────────────────────────────┤\n"
	.ascii "│ Type \"help\" to list all commands                            │\n"
	.asciz "└─────────────────────────────────────────────────────────────┘\n\n"
.equ len_entry_message, . - entry_message

prompt:
	.asciz "tushino$> "
.equ len_prompt, . - prompt

command_help:
	.asciz "help"
.equ len_command_help, . - command_help

command_help_result:
	.ascii "┌───────────┬───────────────────────────────────────────────┐\n"
	.ascii "│  Command  │                  Description                  │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ creat     │ Creates files with a given names              │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ info      │ Prints information about creator              │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ help      │ Prints detailed info about existing commands  │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ mkdir     │ Creates directories with a given names        │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ shutdown  │ Shuts the server down                         │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ task      │ Prints information about server's destiny     │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ time      │ Prints server local time                      │\n"
	.ascii "├───────────┼───────────────────────────────────────────────┤\n"
	.ascii "│ quit      │ Closes connection with server                 │\n"
	.asciz "└───────────┴───────────────────────────────────────────────┘\n"
.equ len_command_help_result, . - command_help_result

command_info:
	.asciz "info"
.equ len_command_info, . - command_info

command_info_result:
	.asciz "© Pavlovsky Anton, 2020\n"
.equ len_command_info_result, . - command_info_result

command_time:
	.asciz "time"
.equ len_command_time, . - command_time

command_task:
	.asciz "task"
.equ len_command_task, . - command_task

command_task_result:
	.ascii "┌──────────────────────────────────────────────────────────┐\n"
	.ascii "│                         Task #15                         │\n"
	.ascii "├──────────────────────────────────────────────────────────┤\n"
	.ascii "│ Add to the server's services support for an additional   │\n"
	.ascii "│ command for creating a file on the server                │\n"
	.ascii "├──────────────────────────────────────────────────────────┤\n"
	.ascii "│ - Input  parameters: names of files                      │\n"
	.ascii "│ - Server's response: command's status                    │\n"
	.asciz "└──────────────────────────────────────────────────────────┘\n"
.equ len_command_task_result, . - command_task_result

command_creat:
	.asciz "creat"
.equ len_command_creat, . - command_creat

command_creat_result:
	.asciz "Creating files... \n\n"
.equ len_command_creat_result, . - command_creat_result

command_mkdir:
	.asciz "mkdir"
.equ len_command_mkdir, . - command_mkdir

command_mkdir_result:
	.asciz "Creating directories... \n\n"
.equ len_command_mkdir_result, . - command_mkdir_result

creat_success:
	.asciz "Success"
.equ len_creat_success, . - creat_success

creat_failed:
	.asciz "Failed"
.equ len_creat_failed, . - creat_failed

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

error_no_such_command:
	.asciz "Error: No such command\n"
.equ len_error_no_such_command, . - error_no_such_command

colon:
	.asciz ": "
.equ len_colon, . - colon

line_feed:
	.asciz "\n"
.equ len_line_feed, . - line_feed

slash:
	.asciz "/"

tserver_log:
	.asciz "tserver: "
.equ len_tserver_log, . - tserver_log

.section .data
var_n:
	.long 0

was_caught:
	.long 0

error_code:
	.long 0

command_time_result:
	.asciz "Server time is xx:xx:xx\n"
.equ len_command_time_result, . - command_time_result

.section .bss
.equ sizeof_buffer, 1024
.lcomm buffer, sizeof_buffer
.lcomm word_buffer, sizeof_buffer
.lcomm error_buffer, sizeof_buffer

.lcomm serv_addr, sizeof_sockaddr_in	# static struct sockaddr_in (0x10 bytes)
.lcomm cli_addr, sizeof_sockaddr_in		# static struct sockaddr_in (0x10 bytes)

.section .text
.globl _start
_start:
	# Daemonize!
	.equ RUN_AS_DAEMON, 0x1

.if RUN_AS_DAEMON == 0x1
	calll make_us_daemon
	testl %eax, %eax
	js start_exit
.endif

.if RUN_AS_DAEMON == 0x1 && LIBC == 0x1
	.equ ENABLE_LOGGING, 0x1
	.equ LOGGING_OFFSET, 0x8
.endif

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

.if ENABLE_LOGGING == 0x1
	leal error_no_port + LOGGING_OFFSET, %eax
	pushl %eax
	pushl $LOG_ERR
	calll syslog
	addl $0x8, %esp
.else
	pushl $len_error_no_port
	pushl $error_no_port
	pushl $STDERR
	calll write
	addl $0xC, %esp
.endif

	jmp start_exit

start_check_ok:
	# Main part
	pushl $sigpipe_handle
	pushl $SIGPIPE
	calll signal
	addl $0x8, %esp

	pushl 8(%ebp)
	calll atoi
	addl $0x4, %esp

	cmpl $0xFFFF, %eax
	jle port_check_ok

.if ENABLE_LOGGING == 0x1
	leal error_port_out + LOGGING_OFFSET, %eax
	pushl %eax
	pushl $LOG_ERR
	calll syslog
	addl $0x8, %esp
.else
	pushl $len_error_port_out
	pushl $error_port_out
	pushl $STDERR
	calll write
	addl $0xC, %esp
.endif

	jmp start_exit

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

.if ENABLE_LOGGING == 0x1
	leal error_socket + LOGGING_OFFSET, %eax
	pushl %eax
	pushl $LOG_ERR
	calll syslog
	addl $0x8, %esp
.else
	pushl $len_error_socket
	pushl $error_socket
	pushl $STDERR
	calll write
	addl $0xC, %esp
.endif

	jmp start_exit

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

.if ENABLE_LOGGING == 0x1
	leal error_bind + LOGGING_OFFSET, %eax
	pushl %eax
	pushl $LOG_ERR
	calll syslog
	addl $0x8, %esp
.else
	pushl $len_error_bind
	pushl $error_bind
	pushl $STDERR
	calll write
	addl $0xC, %esp
.endif

	jmp start_exit

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

.if ENABLE_LOGGING == 0x1
	leal error_accept + LOGGING_OFFSET, %eax
	pushl %eax
	pushl $LOG_ERR
	calll syslog
	addl $0x8, %esp
.else
	pushl $len_error_accept
	pushl $error_accept
	pushl $STDERR
	calll write
	addl $0xC, %esp
.endif

	jmp start_exit

accept_check_ok:
	movl %eax, newsockfd(%ebp)

	pushl $len_entry_message
	pushl $entry_message
	pushl newsockfd(%ebp)
	calll write
	addl $0xC, %esp

	cmpl $0x0, %eax
	jge write_entry_check_ok

.if ENABLE_LOGGING == 0x1
	leal error_write + LOGGING_OFFSET, %eax
	pushl %eax
	pushl $LOG_ERR
	calll syslog
	addl $0x8, %esp
.else
	pushl $len_error_write
	pushl $error_write
	pushl $STDERR
	calll write
	addl $0xC, %esp
.endif

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
	jz while_not_shutdown_end

signal_goes_here:
	pushl newsockfd(%ebp)
	calll closesocket
	addl $0x4, %esp

	jmp while_not_shutdown

while_not_shutdown_end:
	pushl sockfd(%ebp)
	calll closesocket
	addl $0x4, %esp

start_exit:
	# Exitting
	pushl $EXIT_SUCCESS
	calll exit

.type performator, @function
.equ SHUTDOWN_COMMAND, 0
.equ QUIT_COMMAND, 1
.equ CAUGHT_COMMAND, 2
performator:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
while_true:
	movl $0x0, was_caught

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
	pushl $buffer
	pushl $command_time
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz time_check_fail

	pushl first_arg(%ebp)
	calll print_time
	addl $0x4, %esp

	jmp while_true

time_check_fail:
	cmpb $' ', buffer + 0x5
	jne error_with_commands

	movb $0x0, buffer + 0x5

	pushl $buffer
	pushl $command_creat
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz creat_check_fail

	pushl $len_command_creat_result
	pushl $command_creat_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	pushl $creat
	pushl first_arg(%ebp)
	calll proceed_creat
	addl $0x4, %esp

	jmp while_true

creat_check_fail:
	pushl $buffer
	pushl $command_mkdir
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jnz error_with_commands

	pushl $len_command_mkdir_result
	pushl $command_mkdir_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	pushl $mkdir
	pushl first_arg(%ebp)
	calll proceed_creat
	addl $0x4, %esp

	jmp while_true

error_with_commands:
	cmpl $0x0, was_caught
	je was_not_caught

	movl $CAUGHT_COMMAND, %eax
	jmp while_true_end

was_not_caught:
	pushl $len_error_no_such_command
	pushl $error_no_such_command
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp
	
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

.if LIBC == 0x1
.section .data
time_string:
	.asciz "Server time is %s"

.section .bss
.lcomm time_buf, 50

.section .text
.type print_time, @function
print_time:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	subl $0x8, %esp # Acquiring space for two variables
	.equ rawtime, -sizeof_int			# auto time_t (0x4 bytes)
	.equ timeinfo, rawtime - sizeof_int	# auto struct tm * (0x4 bytes)

	# Main part
	pushl $0x0
	calll time
	addl $0x4, %esp

	movl %eax, rawtime(%ebp)

	leal rawtime(%ebp), %eax
	pushl %eax
	calll localtime
	addl $0x4, %esp

	movl %eax, timeinfo(%ebp)

	pushl %eax
	calll asctime
	addl $0x4, %esp

	pushl %eax
	pushl $time_string
	pushl $time_buf
	calll sprintf
	addl $0xC, %esp

	pushl $time_buf
	calll lstrlen
	addl $0x4, %esp

	pushl %eax
	pushl $time_buf
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.else
.type print_time, @function
.equ SYS_TIME, 13
.equ SECS_PER_HOUR, 60 * 60
.equ SECS_PER_DAY, SECS_PER_HOUR * 24
.equ UTC_MSK, 0x3
print_time:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	subl $0xC, %esp
	.equ tm_hour, -sizeof_int			# auto int (0x4 bytes)
	.equ tm_min, tm_hour - sizeof_int	# auto int (0x4 bytes)
	.equ tm_sec, tm_min - sizeof_int	# auto int (0x4 bytes)

	# Saving registers
	pushl %ebx

	# Syscall
	movl $SYS_TIME, %eax
	xorl %ebx, %ebx
	int $0x80 # 0x80's interrupt

	# Initializing variables
	xorl %edx, %edx
	movl $SECS_PER_DAY, %ecx

	# Main part
	idivl %ecx

	movl %edx, %eax
	xorl %edx, %edx
	movl $SECS_PER_HOUR, %ecx
	idivl %ecx

	addl $UTC_MSK, %eax
	movl %eax, tm_hour(%ebp)

	movl %edx, %eax
	xorl %edx, %edx
	movl $60, %ecx
	idivl %ecx

	movl %eax, tm_min(%ebp)
	movl %edx, tm_sec(%ebp)

	.equ HOUR_OFFSET, 15
	.equ MIN_OFFSET, 18
	.equ SEC_OFFSET, 21

	movb $'0', command_time_result + HOUR_OFFSET
	movb $'0', command_time_result + HOUR_OFFSET + 1

	pushl $0x2
	leal command_time_result + HOUR_OFFSET, %eax
	pushl %eax
	pushl tm_hour(%ebp)
	call itoa
	addl $0xC, %esp

	movb $'0', command_time_result + MIN_OFFSET
	movb $'0', command_time_result + MIN_OFFSET + 1

	pushl $0x2
	leal command_time_result + MIN_OFFSET, %eax
	pushl %eax
	pushl tm_min(%ebp)
	call itoa
	addl $0xC, %esp

	movb $'0', command_time_result + SEC_OFFSET
	movb $'0', command_time_result + SEC_OFFSET + 1

	pushl $0x2
	leal command_time_result + SEC_OFFSET, %eax
	pushl %eax
	pushl tm_sec(%ebp)
	call itoa
	addl $0xC, %esp

	pushl $len_command_time_result
	pushl $command_time_result
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

# char *itoa(int num, char *buffer, int bufsize);
# Converts number to a nonzero-terminated string. Bounds are being checked

# Numbers should be positive!!!
.type itoa, @function
itoa:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl first_arg(%ebp), %eax
	movl third_arg(%ebp), %ecx

	# Main part
itoa_while:
	testl %eax, %eax
	jz itoa_while_end

	testl %ecx, %ecx
	jz itoa_while_end

	movl $0xA, %ebx
	xorl %edx, %edx
	idivl %ebx

	addb $'0', %dl

	movl second_arg(%ebp), %ebx
	movb %dl, -1(%ebx, %ecx)

	decl %ecx

	jmp itoa_while

itoa_while_end:
	# Returning value
	movl second_arg(%ebp), %eax

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl
.endif

.type sigpipe_handle, @function
sigpipe_handle:
	# Main part
	movl $0x1, was_caught

	retl

.type make_us_daemon, @function
.equ DAEMON_FAIL, -1
make_us_daemon:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Main part
	calll fork

	testl %eax, %eax
	js make_us_daemon_fail

	jz make_us_daemon_fork_ok

	pushl $EXIT_SUCCESS
	calll exit

make_us_daemon_fork_ok:
	calll setsid

	testl %eax, %eax
	js make_us_daemon_fail

	pushl $SIG_IGN
	pushl $SIGCHLD
	calll signal
	addl $0x8, %esp

	pushl $SIG_IGN
	pushl $SIGHUP
	calll signal
	addl $0x8, %esp

	calll fork

	testl %eax, %eax
	js make_us_daemon_fail

	jz make_us_daemon_fork_ok_2

	pushl $EXIT_SUCCESS
	calll exit

make_us_daemon_fork_ok_2:
	pushl $0x0
	calll umask
	addl $0x4, %esp

	pushl $slash
	calll chdir
	addl $0x6, %esp

	pushl $STDERR
	calll close
	addl $0x4, %esp

	pushl $STDOUT
	calll close
	addl $0x4, %esp

	pushl $STDIN
	calll close
	addl $0x4, %esp

.if ENABLE_LOGGING == 0x1
	pushl $LOG_DAEMON
	pushl $LOG_PID
	pushl $tserver_log
	calll openlog
	addl $0xC, %esp
.endif

	xorl %eax, %eax

	jmp make_us_daemon_exit

make_us_daemon_fail:
	movl $DAEMON_FAIL, %eax

make_us_daemon_exit:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type proceed_creat, @function
proceed_creat:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	leal buffer + 0x6, %edx

	# Main part
proceed_creat_while:
	movl $0x0, error_code

	cmpb $0x0, (%edx)
	je proceed_creat_while_end

	# Saving registers
	pushl %edx

	xorl %eax, %eax
	movb (%edx), %al
	pushl %eax
	calll check_whitespace
	addl $0x4, %esp

	# Restoring registers
	popl %edx

	testl %eax, %eax
	jnz proceed_creat_while_white

	# Saving registers
	pushl %edx

	pushl %edx
	calll get_next_word
	addl $0x4, %esp

	# Restoring registers
	popl %edx

	addl %eax, %edx # Adding word lenght

	# Saving registers
	pushl %eax
	pushl %edx

	pushl $STD_PERMS
	pushl $word_buffer
	calll *second_arg(%ebp)
	addl $0x8, %esp

	testl %eax, %eax
	jns proceed_creat_while_creat_ok

	negl %eax
	movl %eax, error_code

proceed_creat_while_creat_ok:
	# Restoring registers
	popl %edx
	popl %eax

	# Saving registers
	pushl %edx

	pushl %eax
	pushl $word_buffer
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	pushl $len_colon
	pushl $colon
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

.if LIBC == 1
	pushl error_code
	calll strerror
	addl $0x4, %esp

	# Saving registers
	pushl %eax

	pushl %eax
	calll lstrlen
	addl $0x4, %esp

	# Restoring registers
	popl %edx

	pushl %eax
	pushl %edx
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp
.else
	cmpl $0x0, error_code
	je proceed_creat_while_no_error

	pushl $len_creat_failed
	pushl $creat_failed
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	jmp proceed_creat_while_continue

proceed_creat_while_no_error:
	pushl $len_creat_success
	pushl $creat_success
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

proceed_creat_while_continue:
.endif

	pushl $len_line_feed
	pushl $line_feed
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	# Restoring registers
	popl %edx

	jmp proceed_creat_while

proceed_creat_while_white:
	incl %edx
	jmp proceed_creat_while
	
proceed_creat_while_end:
	pushl $len_line_feed
	pushl $line_feed
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type check_whitespace, @function
check_whitespace:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Saving registers
	pushl %esi
	pushl %edi

	# Initializing variables
	xorl %eax, %eax
	xorl %ecx, %ecx
	xorl %esi, %esi
	movl $0x1, %edi
	movl first_arg(%ebp), %edx

	# Main part
	cmpb $' ', %dl
	cmovel %edi, %ecx
	cmovnel %esi, %ecx
	orl %ecx, %eax

	cmpb $0xC, %dl # \f FF
	cmovel %edi, %ecx
	cmovnel %esi, %ecx
	orl %ecx, %eax

	cmpb $0xA, %dl # \n NL
	cmovel %edi, %ecx
	cmovnel %esi, %ecx
	orl %ecx, %eax

	cmpb $0xD, %dl # \r CR
	cmovel %edi, %ecx
	cmovnel %esi, %ecx
	orl %ecx, %eax

	cmpb $0x9, %dl # \t HT
	cmovel %edi, %ecx
	cmovnel %esi, %ecx
	orl %ecx, %eax

	cmpb $0xB, %dl # \v VT
	cmovel %edi, %ecx
	cmovnel %esi, %ecx
	orl %ecx, %eax

	# Restoring registers
	popl %edi
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type get_next_word, @function
get_next_word:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl first_arg(%ebp), %edx
	xorl %ecx, %ecx

	# Main part
get_next_word_while:
	cmpb $0x0, (%edx, %ecx)
	je get_next_word_while_end

	# Saving registers
	pushl %ecx
	pushl %edx

	pushl (%edx, %ecx)
	calll check_whitespace
	addl $0x4, %esp

	# Restoring registers
	popl %edx
	popl %ecx

	testl %eax, %eax
	jnz get_next_word_while_end

	incl %ecx

	jmp get_next_word_while

get_next_word_while_end:
	# Saving registers
	pushl %ecx

	pushl %ecx
	pushl %edx
	pushl $word_buffer
	calll lstrncpy
	addl $0xC, %esp

	# Restoring registers
	popl %ecx

	movb $0x0, word_buffer(%ecx)

	# Returning value
	movl %ecx, %eax

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

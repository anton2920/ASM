# For constants definitions
.equ LIBC, 0x1

.equ STD_PERMS, 0755
.equ O_RDONLY, 0
.equ O_RDWR, 2

.equ STDOUT, 1
.equ STDIN, 0
.equ STDERR, 2

.equ sizeof_int, 4
.equ first_arg, sizeof_int + sizeof_int
.equ second_arg, first_arg + sizeof_int
.equ third_arg, second_arg + sizeof_int
.equ fourth_arg, third_arg + sizeof_int
.equ fifth_arg, fourth_arg + sizeof_int

.equ SEEK_SET, 0
.equ SEEK_CUR, 1
.equ SEEK_END, 2

# typedef enum {
#	false,
#	true	
# } bool;
.equ sizeof_bool, 1
.equ false, 0
.equ true, 1

# struct sockaddr_in {
#        short   sin_family;
#        u_short sin_port;
#        struct  in_addr sin_addr;
#        char    sin_zero[8];
# };
.equ sizeof_sockaddr_in, 0x10
.equ sockaddr_in_sin_family, 0x0
.equ sockaddr_in_sin_port, 0x2
.equ sockaddr_in_sin_addr, 0x4
.equ sockaddr_in_sin_zero, 0x8

# socket(2) arguments
.equ AF_INET, 0x2
.equ SOCK_STREAM, 0x1
.equ PROTOCOL, 0x0

.equ INADDR_ANY, 0x0

# shutdown(2) arguments
.equ SHUT_RD, 0
.equ SHUT_WR, SHUT_RD + 1
.equ SHUT_RDWR, SHUT_WR + 1

# setsockopt(2) arguments
.equ SOL_SOCKET, 1
.equ SO_REUSEADDR, 2

# exit(2) arguments
.equ EXIT_SUCCESS, 0
.equ EXIT_FAILURE, 1

# signal(2) arguments
.equ SIG_IGN, 1
.equ SIGPIPE, 0xD
.equ SIGCHLD, 0x11
.equ SIGHUP, 0x1

.if LIBC == 1
# openlog(3) arguments
.equ LOG_PID, 0x1
.equ LOG_DAEMON, 3 << 3

# syslog(3) arguments
.equ LOG_ERR, 0x3
.endif

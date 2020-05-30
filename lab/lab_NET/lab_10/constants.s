# For constants definitions
.equ STD_PERMS, 0666
.equ O_RDONLY, 0
.equ O_RDWR, 2

.equ STDOUT, 1
.equ STDIN, 0
.equ STDERR, 2

.equ sizeof_int, 4
.equ first_arg, sizeof_int + sizeof_int
.equ second_arg, first_arg + sizeof_int
.equ third_arg, second_arg + sizeof_int

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

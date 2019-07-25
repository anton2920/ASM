# For constants definitions
.equ LIBC_ENABLED, 1

.equ STD_PERMS, 0666
.equ O_RDONLY, 0
.equ O_RDWR, 2

.equ STDOUT, 1
.equ STDIN, 0

.equ sizeof_int, 4
.equ first_arg, sizeof_int + sizeof_int
.equ second_arg, first_arg + sizeof_int
.equ third_arg, second_arg + sizeof_int

.equ SEEK_SET, 0
.equ SEEK_CUR, 1
.equ SEEK_END, 2

# .equ PASS_ERR, -1

.equ sizeof_bool, 1
.equ false, 0
.equ true, 1
# typedef enum {
#	false,
#	true	
# } bool;

# For constants definitions
.equ LIBC_ENABLED, 1

.equ STD_PERMS, 0666
.equ O_RDONLY, 0
.equ O_WRONLY, 1
.equ O_RDWR, 2
.equ O_WRTRUNC, 513

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

# Database
# struct db {
#	int hash; /* header */
#	int lastId; /* header */
#	struct group grList[];
# }

.equ HEADER_SIZE, sizeof_int + sizeof_int

.equ STRUCT_SIZE, 21
.equ NAME_SIZE, 8
.equ iD, 0
.equ NAME, iD + sizeof_int
.equ YEAR, NAME + NAME_SIZE
.equ QUANT, YEAR + sizeof_int
.equ FLAG, QUANT + sizeof_int
# struct group {
#	int id;
#	char NAME[NAME_SIZE];
#	int YEAR;
#	int QUANT;
#	bool FLAG;
# };

.equ sizeof_bool, 1
.equ false, 0
.equ true, 1
# typedef enum {
#	false,
#	true	
# } bool;

.equ INT_MAX_LEN, 10
.equ YEAR_MAX_LEN, 5
.equ GR_SIZE_MAX_LEN, 3

.equ SYS_MMAP, 90
.equ SYS_MUNMAP, 91

.equ PROT_NONE, 0x0
.equ PROT_READ, 0x1
.equ PROT_WRITE, 0x2
.equ PROT_EXEC, 0x4

.equ PROT_RDWR, 0x3 # PROT_READ | PROT_WRITE

.equ MAP_SHARE, 0x1
.equ MAP_PRIVATE, 0x2

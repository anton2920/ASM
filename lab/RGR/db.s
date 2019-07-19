# Database
# struct db {
#	int lastId;
#	int hash;
#	struct group grList[];
# }

.equ STDIN, 0
.equ STDOUT, 1

.equ first_arg, sizeof_int + sizeof_int
.equ second_arg, first_arg + sizeof_int

.equ sizeof_int, 4

.equ sizeof_bool, 1
.equ false, 0
.equ true, 1
# typedef enum {
#	false,
#	true	
# } bool;

.equ STRUCT_SIZE, 22
.equ NAME_SIZE, 7
.equ NAME, 0
.equ YEAR, NAME_SIZE
.equ QUANT, YEAR + sizeof_int
.equ FLAG, QUANT + sizeof_bool
# struct group {
#	char NAME[NAME_SIZE];
#	int YEAR;
#	int QUANT;
#	bool FLAG;
# };

.section .rodata
header:
	.ascii "| Group name | Admission year | #of_students | Is graduated? |\n\0"
	.equ len_header, . - header
yes:
	.ascii "yes |\n\0"
	.equ len_yes, . - yes
no:
	.ascii "no  |\n\0"
	.equ len_no, . - no
vert_line:
	.ascii " | \0"
	.equ len_vert_line, . - vert_line
table_fd:
	.asciz "| Table fD: "
	.equ len_table_fd, . - table_fd

.section .text
.globl show_recs
.type show_recs, @function
show_recs:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ struct_1, -4
	subl $STRUCT_SIZE, %esp # Acquiring space for struct group

	# I/O flow
	pushl $len_table_fd
	pushl $table_fd
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl first_arg(%ebp)
	call iprint
	addl $0x4, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp

	call prt_ln

	pushl $len_header
	pushl $header
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

show_recs_loop:
	# Main part
	pushl $STRUCT_SIZE
	leal struct_1(%ebp), %eax
	pushl first_arg(%ebp)
	pushl %eax
	call read
	addl $0xC, %esp

	test %eax, %eax
	jz show_recs_loop_end

	pushl $'|'
	call lputchar

	pushl $' '
	call lputchar

	pushl $' '
	call lputchar

	addl $0xC, %esp

	pushl $NAME_SIZE
	pushl NAME + struct_1(%ebp)
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp show_recs_loop

show_recs_loop_end:

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl djb2
.type djb2, @function
djb2:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ hash, -4
	subl $0x4, %esp # Acquiring space in hash(%ebp)

	# Saving registers
	pushl %esi

	# Initializing variables
	movl $5381, hash(%ebp)
	movl first_arg(%ebp), %esi

	# Main part
djb2_while:
	xorl %eax, %eax
	cld
	lodsb
	testb %al, %al
	jz djb2_while_end

	movl hash(%ebp), %edx
	shll $0x5, %edx
	addl %edx, %edx
	addl %eax, %edx
	movl %edx, hash(%ebp)

	jmp djb2_while

djb2_while_end:
	# Returning value
	movl hash(%ebp), %eax

	# Restoring registers
	popl %esi

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

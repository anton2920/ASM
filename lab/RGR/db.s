.include "constants.s"

.section .rodata
# Create and open database
filename_line:
	.ascii "| Type filename: \0"
	.equ len_filename_line, . - filename_line
file_exists:
	.ascii "| database: file already exists                              |\n\0"
	.equ len_file_exists, . - file_exists
change_name:
	.ascii "| Would you like to change filename? [Y/n]: \0"
	.equ len_change_name, . - change_name
error_creating:
	.ascii "| database: error with creating database                     |\n\0"
	.equ len_error_creating, . - error_creating
lookout_for_cr:
	.ascii "| database: created successfully. Lookout for creation? [Y/n]: \0"
	.equ len_lookout_for_cr, . - lookout_for_cr
error_open:
	.ascii "| database: error with opening database                      |\n\0"
	.equ len_error_open, . - error_open
enter_pass:
	.asciz "| Type password: "
	.equ len_enter_pass, . - enter_pass
reenter_pass:
	.asciz "| Retype password: "
	.equ len_reenter_pass, . - reenter_pass
minus_one:
	.long -1
error_pass:
	.asciz "| database: paswords mismatch                                |\n"
	.equ len_error_pass, . - error_pass
pass_too_many:
	.asciz "| database: too many incorrect password attempts             |\n"
	.equ len_pass_too_many, . - pass_too_many
int_zero:
	.long 0

# Show records
header:
	.asciz "|      ID | Group name | Admis. year | #of_students |  Grad? |\n"
	.equ len_header, . - header
yes:
	.ascii "yes  |\n\0"
	.equ len_yes, . - yes
no:
	.ascii "no   |\n\0"
	.equ len_no, . - no
vert_line:
	.ascii " |\t\0"
	.equ len_vert_line, . - vert_line
vert_line_tab:
	.asciz " |\t\t"
	.equ len_vert_line_tab, . - vert_line_tab
number_of_recs:
	.asciz "| Total number of records: "
	.equ len_number_of_recs, . - number_of_recs


# Add records
add_type_name:
	.asciz "| Type group name: "
	.equ len_add_type_name, . - add_type_name
add_type_year:
	.asciz "| Type admission year: "
	.equ len_add_type_year, . - add_type_year
add_type_number:
	.asciz "| Type the number of students: "
	.equ len_add_type_number, . - add_type_number
add_type_grad:
	.asciz "| Is this group graduated? [Y/n]: "
	.equ len_add_type_grad, . - add_type_grad
add_invalid:
	.asciz "| database: invalid input                                    |\n"
	.equ len_add_invalid, . - add_invalid
add_more_records:
	.asciz "| Would you like to add another record? [Y/n]: "
	.equ len_add_more_records, . - add_more_records

# Edit records
edit_type_number:
	.asciz "| Type the iD of a record to edit: "
	.equ len_edit_type_number, . - edit_type_number
edit_invalid_id:
	.asciz "| database: couldn't find a record with that iD              |\n"
	.equ len_edit_invalid_id, . - edit_invalid_id
edit_retype_number:
	.asciz "| Would you like to change the iD? [Y/n]: "
	.equ len_edit_retype_number, . - edit_retype_number
edit_more_records:
	.asciz "| Would you like to edit another record? [Y/n]: "
	.equ len_edit_more_records, . - edit_more_records

.section .bss
.equ FILENAME_LEN, 500
.lcomm FILENAME, FILENAME_LEN

.equ PASSBUF_LEN, 500
.lcomm PASSBUF1, PASSBUF_LEN
.lcomm PASSBUF2, PASSBUF_LEN

.equ ADD_REC_LEN, 30
.lcomm ADD_REC_BUF, ADD_REC_LEN

.section .text
.globl create_database
.type create_database, @function
create_database: 
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ fd, -4
	.equ hash_sum, -8
	subl $0x8, %esp # Acquiring space in fd(%ebp)

	# Saving registers
	pushl %ebx

create_database_loop:
	# I/O flow
	pushl $len_filename_line
	pushl $filename_line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $FILENAME_LEN
	pushl $FILENAME
	pushl $0x0
	call read
	addl $0xC, %esp

	movl $FILENAME, %ebx
	movb $0x0, -1(%ebx, %eax, 1)

	call prt_ln

	# Main part
	pushl $STD_PERMS
	pushl $O_RDONLY
	pushl $FILENAME
	call open
	addl $0xC, %esp

	cmpl $0x0, %eax
	jle create_database_create

	pushl %eax
	call close
	addl $0x4, %esp

	jmp create_database_fileexists

create_database_create:
	pushl $STD_PERMS
	pushl $FILENAME
	call creat
	addl $0x8, %esp

	test %eax, %eax
	jle create_database_err

	# Saving registers
	pushl %eax
	call close
	addl $0x4, %esp

	pushl $STD_PERMS
	pushl $O_RDWR
	pushl $FILENAME
	call open
	addl $0xC, %esp

	test %eax, %eax
	jle create_database_err

	movl %eax, fd(%ebp)

create_database_pass:
	# Ask for pass
	pushl $len_enter_pass
	pushl $enter_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

# .if LIBC_ENABLED == 1
	pushl $0x0
	call turn_echo
	addl $0x4, %esp
# .endif

	pushl $PASSBUF_LEN
	pushl $PASSBUF1
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $PASSBUF1, %ebx
	movb $0x0, -1(%ebx, %eax)

	# Saving registers
	pushl %eax

.if LIBC_ENABLED == 1
	pushl $0x1
	call turn_echo
	addl $0x4, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp
.endif

	# Ask for pass (again)
	pushl $len_reenter_pass
	pushl $reenter_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

.if LIBC_ENABLED == 1
	pushl $0x0
	call turn_echo
	addl $0x4, %esp
.endif

	pushl $PASSBUF_LEN
	pushl $PASSBUF2
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $PASSBUF2, %ebx
	movb $0x0, -1(%ebx, %eax)

	# Saving registers
	pushl %eax

.if LIBC_ENABLED == 1
	pushl $0x1
	call turn_echo
	addl $0x4, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp
.endif

	call prt_ln

	pushl $PASSBUF1
	pushl $PASSBUF2
	call lstrcmp
	addl $0x8, %esp

	test %eax, %eax
	jnz create_database_pass_err

	# Restoring registers
	popl %eax

	pushl $sizeof_int

	cmpl $0x1, %eax
	jne make_hash_sum

	pushl $minus_one

	jmp create_database_lookout

make_hash_sum:
	pushl $PASSBUF1
	call djb2
	addl $0x4, %esp

	movl %eax, hash_sum(%ebp)
	leal hash_sum(%ebp), %eax
	pushl %eax

create_database_lookout:
	pushl fd(%ebp)
	call write
	addl $0xC, %esp

	pushl $sizeof_int
	pushl $int_zero
	pushl fd(%ebp)
	call write
	addl $0xC, %esp

	pushl $SEEK_SET
	pushl $0x0
	pushl fd(%ebp)
	call lseek
	addl $0xC, %esp

	pushl $len_lookout_for_cr
	pushl $lookout_for_cr
	call quit
	addl $0x8, %esp

	test %eax, %eax
	jz create_database_exit_1

	jmp create_database_exit_2

create_database_fileexists:
	pushl $len_file_exists
	pushl $file_exists
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp create_database_change_name

create_database_err:
	pushl $len_error_creating
	pushl $error_creating
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

create_database_change_name:
	pushl $len_change_name
	pushl $change_name
	call quit
	addl $0x8, %esp

	test %eax, %eax
	jz create_database_exit_1

	call prt_ln

	jmp create_database_loop

create_database_pass_err:
	pushl $len_error_pass
	pushl $error_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp create_database_pass

create_database_exit_1:
	call prt_ln

	pushl fd(%ebp)
	call close
	addl $0x4, %esp

	xorl %eax, %eax
	jmp create_database_exit

create_database_exit_2:
	# Returning value
	movl fd(%ebp), %eax

create_database_exit:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp

	# Returning
	retl

.globl open_database
.type open_database, @function
.equ PASS_ERR, -1
.equ LIM_ATT, 3
open_database:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ fd, -4
	.equ nattempts, -8
	.equ hs, -12
	subl $0xC, %esp # Acquiring space for three variables

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl $0x0, nattempts(%ebp)

open_database_loop:
	# I/O flow
	pushl $len_filename_line
	pushl $filename_line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $FILENAME_LEN
	pushl $FILENAME
	pushl $0x0
	call read
	addl $0xC, %esp

	movl $FILENAME, %ebx
	movb $0x0, -1(%ebx, %eax, 1)

open_database_open:
	# Main part
	pushl $STD_PERMS
	pushl $O_RDWR
	pushl $FILENAME
	call open
	addl $0xC, %esp

	# Saving registers
	movl %eax, fd(%ebp)

	cmpl $0x0, %eax
	jg open_database_pass

open_database_err:
	call prt_ln

	pushl $len_error_open
	pushl $error_open
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

open_database_change_name:
	pushl $len_change_name
	pushl $change_name
	call quit
	addl $0x8, %esp

	test %eax, %eax
	je open_database_exit_1

	call prt_ln

	jmp open_database_loop

open_database_pass:
	call prt_ln

	pushl $sizeof_int
	leal hash_sum(%ebp), %eax
	pushl %eax
	pushl fd(%ebp)
	call read
	addl $0xC, %esp

	cmpl $-1, hash_sum(%ebp)
	jz open_database_exit_2

	pushl $len_enter_pass
	pushl $enter_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

.if LIBC_ENABLED == 1
	pushl $0x0
	call turn_echo
	addl $0x4, %esp
.endif

	pushl $PASSBUF_LEN
	pushl $PASSBUF1
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $PASSBUF1, %ebx
	movb $0x0, -1(%ebx, %eax)

.if LIBC_ENABLED
	pushl $0x1
	call turn_echo
	addl $0x4, %esp

	pushl $'\n'
	call lputchar
	addl $0x4, %esp
.endif

	pushl $PASSBUF1
	call djb2
	addl $0x4, %esp

	cmpl %eax, hash_sum(%ebp)
	jz open_database_exit_2

	call prt_ln

	addl $0x1, nattempts(%ebp)

	cmpl $LIM_ATT, nattempts(%ebp)
	jz open_database_exit_error_pass

	pushl $len_error_pass
	pushl $error_pass
	pushl $STDOUT
	call write
	addl $0xC, %esp

	jmp open_database_pass

open_database_exit_1:
	xorl %eax, %eax
	jmp open_database_exit

open_database_exit_error_pass:
	pushl $len_pass_too_many
	pushl $pass_too_many
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl fd(%ebp)
	call close
	addl $0x4, %esp

	# movl $PASS_ERR, %eax

	jmp open_database_exit_1

open_database_exit_2:
	pushl $SEEK_SET
	pushl $0x0
	pushl fd(%ebp)
	call lseek
	addl $0xC, %esp

	# Returning value
	movl fd(%ebp), %eax

open_database_exit:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp

	# Returning
	retl

.globl show_recs
.type show_recs, @function
show_recs:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ struct_1, -STRUCT_SIZE
	subl $STRUCT_SIZE, %esp # Acquiring space for struct group

	# I/O flow
	pushl $len_number_of_recs
	pushl $number_of_recs
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl first_arg(%ebp)
	call find_size
	addl $0x4, %esp

	subl $HEADER_SIZE, %eax

	xorl %edx, %edx
	movl $STRUCT_SIZE, %ebx

	idivl %ebx

	pushl %eax
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

	# Main part
	pushl $SEEK_SET
	pushl $HEADER_SIZE
	pushl first_arg(%ebp)
	call lseek
	addl $0xC, %esp

show_recs_loop:
	# Reading values
	pushl $STRUCT_SIZE
	leal struct_1(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	call read
	addl $0xC, %esp

	cmpl $0x0, %eax
	jle show_recs_loop_end

	# Printing values
	pushl $'|'
	call lputchar

	pushl $'\t'
	call lputchar
	addl $0x8, %esp

	pushl struct_1 + iD(%ebp)
	call iprint
	addl $0x4, %esp

	call print_vert_line

	pushl $NAME_SIZE
	leal struct_1 + NAME(%ebp), %eax
	pushl %eax
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call print_vert_line

	pushl struct_1 + YEAR(%ebp)
	call iprint
	addl $0x4, %esp

	call print_vert_line

	pushl $'\t'
	call lputchar
	addl $0x4, %esp

	pushl struct_1 + QUANT(%ebp)
	call iprint
	addl $0x4, %esp

	pushl $' '
	call lputchar
	addl $0x4, %esp

	call print_vert_line

	cmpb $0x0, struct_1 + FLAG(%ebp)
	jnz show_recs_print_yes

	pushl $len_no
	pushl $no

	jmp show_recs_print_fin

show_recs_print_yes:
	pushl $len_yes
	pushl $yes

show_recs_print_fin:
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

.globl add_records
.type add_records, @function
add_records:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ st_gr, -STRUCT_SIZE
	subl $STRUCT_SIZE, %esp # Acquiring space for struct group

	# Initializing variables
	movl $0x0, st_gr + iD(%ebp)
	movl $0x0, st_gr + NAME(%ebp)
	movl $0x0, st_gr + NAME + sizeof_int(%ebp)

	# Main part
	pushl $SEEK_SET
	pushl $sizeof_int
	pushl first_arg(%ebp)
	call lseek
	addl $0xC, %esp

	pushl $sizeof_int
	leal st_gr + iD(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	call read
	addl $0xC, %esp

	pushl $SEEK_END
	pushl $0x0
	pushl first_arg(%ebp)
	call lseek
	addl $0xC, %esp

add_records_read:
	addl $0x1, st_gr + iD(%ebp)

add_records_read_do_while_0:
	pushl $len_add_type_name
	pushl $add_type_name
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $NAME_SIZE
	leal st_gr + NAME(%ebp), %eax
	pushl %eax
	pushl $STDIN
	call read
	addl $0xC, %esp

	cmpl $NAME_SIZE - 1, %eax
	jle add_records_read_do_while_0_end

	call prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp add_records_read_do_while_0

add_records_read_do_while_0_end:
	movb $0x0, st_gr + NAME - 1(%ebp, %eax)

add_records_read_do_while_1:
	pushl $len_add_type_year
	pushl $add_type_year
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $ADD_REC_BUF, %edx
	movb $0x0, -1(%edx, %eax)

	cmpl $YEAR_MAX_LEN, %eax
	jle add_records_read_do_while_1_end

	call prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp add_records_read_do_while_1

add_records_read_do_while_1_end:
	pushl $ADD_REC_BUF
	call atoi
	addl $0x4, %esp

	movl %eax, st_gr + YEAR(%ebp)

add_records_read_do_while_2:
	pushl $len_add_type_number
	pushl $add_type_number
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $ADD_REC_BUF, %edx
	movb $0x0, -1(%edx, %eax)

	cmpl $GR_SIZE_MAX_LEN, %eax
	jle add_records_read_do_while_2_end

	call prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp add_records_read_do_while_2

add_records_read_do_while_2_end:
	pushl $ADD_REC_BUF
	call atoi
	addl $0x4, %esp

	movl %eax, st_gr + QUANT(%ebp)

	pushl $len_add_type_grad
	pushl $add_type_grad
	call quit
	addl $0x8, %esp

	movb %al, st_gr + FLAG(%ebp)

	pushl $STRUCT_SIZE
	leal st_gr(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	call write
	addl $0xC, %esp

	call prt_ln

	pushl $len_add_more_records
	pushl $add_more_records
	call quit
	addl $0x8, %esp

	testl %eax, %eax
	jz add_records_read_end

	call prt_ln

	jmp add_records_read

add_records_read_end:
	pushl st_gr + iD(%ebp)
	pushl first_arg(%ebp)
	call fix_last_id
	addl $0x8, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type fix_last_id, @function
fix_last_id:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ file_size, -4
	.equ mappedfile, -8
	subl $0x8, %esp # Acquiring space for two variables

	# Saving registers
	pushl %ebx
	
	# Main part	
	pushl first_arg(%ebp)
	call find_size
	addl $0x4, %esp

	movl %eax, file_size(%ebp)

	# Syscall
	pushl $0x0
	pushl first_arg(%ebp)
	pushl $0x1 # Map shared
	pushl $0x3 # Prot read/write
	pushl file_size(%ebp)
	pushl $0x0
	movl %esp, %ebx
	movl $SYS_MMAP, %eax
	int $0x80 # 0x80's interrupt
	addl $0x18, %esp

	movl %eax, mappedfile(%ebp)

	movl second_arg(%ebp), %ecx
	movl mappedfile(%ebp), %edx
	movl %ecx, sizeof_int(%edx)

	# Syscall
	movl file_size(%ebp), %ecx
	movl mappedfile(%ebp), %ebx
	movl $SYS_MUNMAP, %eax
	int $0x80 # 0x80's interrupt

	pushl $SEEK_SET
	pushl $0x0
	pushl first_arg(%ebp)
	call lseek
	addl $0xC, %esp

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.type print_vert_line, @function
print_vert_line:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Final output
	pushl $len_vert_line
	pushl $vert_line
	pushl $STDOUT
	call write
	addl $0xC, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl edit_record
.type edit_record, @function
edit_record:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ file_size, -4
	.equ mappedfile, -8
	.equ curr_id, -12
	.equ last_id, -16
	.equ ed_stGr, -STRUCT_SIZE + last_id
	addl $ed_stGr, %esp

	.equ curr_mfile_pos, ed_stGr - sizeof_int
	subl $sizeof_int, %esp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl $0x0, ed_stGr + iD(%ebp)
	movl $0x0, ed_stGr + NAME(%ebp)
	movl $0x0, ed_stGr + NAME + sizeof_int(%ebp)
	
	# Main part	
	pushl first_arg(%ebp)
	call find_size
	addl $0x4, %esp

	movl %eax, file_size(%ebp)

	# Syscall
	pushl $0x0
	pushl first_arg(%ebp)
	pushl $0x1 # Map shared
	pushl $0x3 # Prot read/write
	pushl file_size(%ebp)
	pushl $0x0
	movl %esp, %ebx
	movl $SYS_MMAP, %eax
	int $0x80 # 0x80's interrupt
	addl $0x18, %esp

	movl %eax, mappedfile(%ebp)

edit_record_start:
edit_record_do_while_1:
	pushl $len_edit_type_number
	pushl $edit_type_number
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $ADD_REC_BUF, %edx
	movb $0x0, -1(%eax, %edx)

	cmpl $INT_MAX_LEN, %eax
	jle edit_record_do_while_1_end

	call prt_ln

	pushl $len_edit_invalid_id
	pushl $edit_invalid_id
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

edit_record_do_while_1_end:
	call prt_ln

	pushl $ADD_REC_BUF
	call atoi
	addl $0x4, %esp

	movl %eax, curr_id(%ebp)

	movl mappedfile(%ebp), %ebx
	addl $HEADER_SIZE, %ebx
	movl -sizeof_int(%ebx), %ecx
	movl %ecx, last_id(%ebp)

	cmpl %ecx, curr_id(%ebp)
	jg edit_record_search_for_id_error

edit_record_search_for_id:
	movl curr_id(%ebp), %ecx
	cmpl %ecx, iD(%ebx)
	jz edit_record_search_for_id_found

	movl last_id(%ebp), %ecx
	cmpl %ecx, iD(%ebx)
	jz edit_record_search_for_id_error

	addl $STRUCT_SIZE, %ebx

	jmp edit_record_search_for_id

edit_record_search_for_id_error:
	pushl $len_edit_invalid_id
	pushl $edit_invalid_id
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	pushl $len_edit_retype_number
	pushl $edit_retype_number
	call quit
	addl $0x8, %esp

	# Saving registers
	pushl %eax

	call prt_ln

	# Restoring registers
	popl %eax

	test %eax, %eax
	jz edit_record_exit

	jmp edit_record_do_while_1

edit_record_search_for_id_found:
	movl %ebx, curr_mfile_pos(%ebp)
	movl curr_id(%ebp), %ecx
	movl %ecx, ed_stGr + iD(%ebp)

edit_records_read_do_while_0:
	pushl $len_add_type_name
	pushl $add_type_name
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $NAME_SIZE
	leal ed_stGr + NAME(%ebp), %eax
	pushl %eax
	pushl $STDIN
	call read
	addl $0xC, %esp

	cmpl $NAME_SIZE - 1, %eax
	jle edit_records_read_do_while_0_end

	call prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp edit_records_read_do_while_0

edit_records_read_do_while_0_end:
	movb $0x0, ed_stGr + NAME - 1(%ebp, %eax)

edit_records_read_do_while_1:
	pushl $len_add_type_year
	pushl $add_type_year
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $ADD_REC_BUF, %edx
	movb $0x0, -1(%edx, %eax)

	cmpl $YEAR_MAX_LEN, %eax
	jle edit_records_read_do_while_1_end

	call prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp edit_records_read_do_while_1

edit_records_read_do_while_1_end:
	pushl $ADD_REC_BUF
	call atoi
	addl $0x4, %esp

	movl %eax, ed_stGr + YEAR(%ebp)

edit_records_read_do_while_2:
	pushl $len_add_type_number
	pushl $add_type_number
	pushl $STDOUT
	call write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	call read
	addl $0xC, %esp

	movl $ADD_REC_BUF, %edx
	movb $0x0, -1(%edx, %eax)

	cmpl $GR_SIZE_MAX_LEN, %eax
	jle edit_records_read_do_while_2_end

	call prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	call write
	addl $0xC, %esp

	call prt_ln

	jmp edit_records_read_do_while_2

edit_records_read_do_while_2_end:
	pushl $ADD_REC_BUF
	call atoi
	addl $0x4, %esp

	movl %eax, ed_stGr + QUANT(%ebp)

	pushl $len_add_type_grad
	pushl $add_type_grad
	call quit
	addl $0x8, %esp

	movb %al, ed_stGr + FLAG(%ebp)

	call prt_ln

	pushl $len_edit_more_records
	pushl $edit_more_records
	call quit
	addl $0x8, %esp

	testl %eax, %eax
	jz edit_record_exit

	call prt_ln

	jmp edit_record_start

edit_record_exit:
	pushl $STRUCT_SIZE
	leal ed_stGr(%ebp), %eax
	pushl %eax
	pushl curr_mfile_pos(%ebp)
	call lstrncpy
	addl $0xC, %esp

	# Syscall
	movl file_size(%ebp), %ecx
	movl mappedfile(%ebp), %ebx
	movl $SYS_MUNMAP, %eax
	int $0x80 # 0x80's interrupt

	pushl $SEEK_SET
	pushl $0x0
	pushl first_arg(%ebp)
	call lseek
	addl $0xC, %esp

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

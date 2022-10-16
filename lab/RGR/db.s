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

# Delete records
delete_type_number:
	.asciz "| Type the iD of a record to delete: "
	.equ len_delete_type_number, . - delete_type_number
delete_success:
	.asciz "| database: record has been deleted successfully             |\n"
	.equ len_delete_success, . - delete_success
delete_more_records:
	.asciz "| Would you like to delete another record? [Y/n]: "
	.equ len_delete_more_records, . - delete_more_records

# Checking integrity
checking_check:
	.asciz "| database: checking integrity... "
	.equ len_checking_check, . - checking_check
checking_ok:
	.asciz "OK                         |\n"
	.equ len_checking_ok, . - checking_ok
checking_fail:
	.asciz "FAIL                       |\n"
	.equ len_checking_fail, . - checking_fail
checking_fix:
	.asciz "| database: all issues have been fixed                       |\n"
	.equ len_checking_fix, . - checking_fix

.section .bss
.equ FILENAME_LEN, PATH_MAX
.lcomm FILENAME, FILENAME_LEN

.equ PASSBUF_LEN, 500
.lcomm PASSBUF1, PASSBUF_LEN
.lcomm PASSBUF2, PASSBUF_LEN

.equ ADD_REC_LEN, 30
.lcomm ADD_REC_BUF, ADD_REC_LEN

.section .text

# int create_database(void);
.globl create_database
.type create_database, @function
create_database: 
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ fd, -4
	.equ hash_sum, -8
	subl $0x8, %esp # Acquiring space for two variables

create_database_loop:
	# I/O flow
	pushl $len_filename_line
	pushl $filename_line
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $FILENAME_LEN
	pushl $FILENAME
	pushl $0x0
	calll read
	addl $0xC, %esp

	movb $0x0, FILENAME - 1(%eax)

	calll prt_ln

	# Check if the file exists
	pushl $0x0
	pushl $FILENAME
	calll access
	addl $0x8, %esp

	testl %eax, %eax
	js create_database_create # access(2) fails -> file doesn't exist?

	# File already exists
	pushl $len_file_exists
	pushl $file_exists
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

create_database_change_name:
	pushl $len_change_name
	pushl $change_name
	calll prompt_yn
	addl $0x8, %esp

	testl %eax, %eax
	jz create_database_exit_1

	calll prt_ln

	jmp create_database_loop

create_database_create:
	pushl $STD_PERMS
	pushl $O_RDWR|O_CREAT|O_TRUNC
	pushl $FILENAME
	calll open
	addl $0xC, %esp

	testl %eax, %eax
	js create_database_err

	movl %eax, fd(%ebp)

	jmp create_database_pass

create_database_err:
	pushl $len_error_creating
	pushl $error_creating
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp create_database_change_name

create_database_pass:
	# Ask for pass
	pushl $len_enter_pass
	pushl $enter_pass
	pushl $STDOUT
	calll write
	addl $0xC, %esp

.if LIBC_ENABLED == 1
	pushl $0x0
	calll turn_echo
	addl $0x4, %esp
.endif

	pushl $PASSBUF_LEN
	pushl $PASSBUF1
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, PASSBUF1 - 1(%eax)

	# Saving registers
	pushl %eax

.if LIBC_ENABLED == 1
	pushl $0x1
	calll turn_echo
	addl $0x4, %esp

	pushl $'\n'
	calll lputchar
	addl $0x4, %esp
.endif

	# Ask for pass (again)
	pushl $len_reenter_pass
	pushl $reenter_pass
	pushl $STDOUT
	calll write
	addl $0xC, %esp

.if LIBC_ENABLED == 1
	pushl $0x0
	calll turn_echo
	addl $0x4, %esp
.endif

	pushl $PASSBUF_LEN
	pushl $PASSBUF2
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, PASSBUF2 - 1(%eax)

	# Saving registers
	pushl %eax

.if LIBC_ENABLED == 1
	pushl $0x1
	calll turn_echo
	addl $0x4, %esp

	pushl $'\n'
	calll lputchar
	addl $0x4, %esp
.endif

	calll prt_ln

	pushl $PASSBUF2
	pushl $PASSBUF1
	calll lstrcmp
	addl $0x8, %esp

	testl %eax, %eax
	jz create_database_pass_ok

	pushl $len_error_pass
	pushl $error_pass
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp create_database_pass

create_database_pass_ok:
	# Restoring registers
	popl %eax

	pushl $sizeof_int # 'nbytes' to further write

	cmpl $0x1, %eax
	jne create_database_make_hash_sum

	movl $NO_PASS, hash_sum(%ebp) # 'buf' to further write

	jmp create_database_lookout

create_database_make_hash_sum:
	pushl $PASSBUF1
	calll djb2
	addl $0x4, %esp

	movl %eax, hash_sum(%ebp)

create_database_lookout:
	leal hash_sum(%ebp), %eax
	pushl %eax # 'buf'
	pushl fd(%ebp)
	calll write
	addl $0xC, %esp

	# Write autoincrement ID field
	pushl $sizeof_int
	pushl $int_zero
	pushl fd(%ebp)
	calll write
	addl $0xC, %esp

	pushl $len_lookout_for_cr
	pushl $lookout_for_cr
	calll prompt_yn
	addl $0x8, %esp

	testl %eax, %eax
	jnz create_database_exit_2

create_database_exit_1:
	calll prt_ln

	pushl fd(%ebp)
	calll close
	addl $0x4, %esp

	# Returning value
	xorl %eax, %eax # return 0 -> no file left opened
	jmp create_database_exit

create_database_exit_2:
	pushl fd(%ebp)
	calll lrewind
	addl $0x4, %esp

	# Returning value
	movl fd(%ebp), %eax

create_database_exit:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl open_database
.type open_database, @function
.equ LIM_ATT, 3
open_database:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ fd, -4
	.equ nattempts, -8
	.equ hash_sum, -12
	subl $0xC, %esp # Acquiring space for three variables

	# Initializing variables
	movl $0x0, nattempts(%ebp)

open_database_loop:
	# I/O flow
	pushl $len_filename_line
	pushl $filename_line
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $FILENAME_LEN
	pushl $FILENAME
	pushl $0x0
	calll read
	addl $0xC, %esp

	movb $0x0, FILENAME - 1(%eax)

open_database_open:
	# Main part
	pushl $STD_PERMS
	pushl $O_RDWR
	pushl $FILENAME
	calll open
	addl $0xC, %esp

	# Saving registers
	movl %eax, fd(%ebp)

	testl %eax, %eax
	jns open_database_pass

open_database_err:
	calll prt_ln

	pushl $len_error_open
	pushl $error_open
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

open_database_change_name:
	pushl $len_change_name
	pushl $change_name
	calll prompt_yn
	addl $0x8, %esp

	testl %eax, %eax
	jz open_database_exit_1

	calll prt_ln

	jmp open_database_loop

open_database_pass:
	calll prt_ln

	pushl $sizeof_int
	leal hash_sum(%ebp), %eax
	pushl %eax
	pushl fd(%ebp)
	calll read
	addl $0xC, %esp

	cmpl $NO_PASS, hash_sum(%ebp)
	je open_database_exit_2

open_database_pass_read:
	pushl $len_enter_pass
	pushl $enter_pass
	pushl $STDOUT
	calll write
	addl $0xC, %esp

.if LIBC_ENABLED == 1
	pushl $0x0
	calll turn_echo
	addl $0x4, %esp
.endif

	pushl $PASSBUF_LEN
	pushl $PASSBUF1
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, PASSBUF1 - 1(%eax)

.if LIBC_ENABLED == 1
	pushl $0x1
	calll turn_echo
	addl $0x4, %esp

	pushl $'\n'
	calll lputchar
	addl $0x4, %esp
.endif

	pushl $PASSBUF1
	calll djb2
	addl $0x4, %esp

	# Saving registers
	pushl %eax

	calll prt_ln

	# Restoring registers
	popl %eax

	cmpl %eax, hash_sum(%ebp)
	je open_database_exit_2


	incl nattempts(%ebp)

	cmpl $LIM_ATT, nattempts(%ebp)
	jge open_database_exit_error_pass

	pushl $len_error_pass
	pushl $error_pass
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp open_database_pass_read

open_database_exit_error_pass:
	pushl $len_pass_too_many
	pushl $pass_too_many
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl fd(%ebp)
	calll close
	addl $0x4, %esp

open_database_exit_1:
	xorl %eax, %eax
	jmp open_database_exit

open_database_exit_2:
	pushl fd(%ebp)
	calll lrewind
	addl $0x4, %esp

	# Returning value
	movl fd(%ebp), %eax

open_database_exit:
	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl show_recs
.type show_recs, @function
show_recs:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ struct_1, -STRUCT_SIZE
	subl $STRUCT_SIZE, %esp # Acquiring space for 'struct group'

	# I/O flow
	pushl $len_number_of_recs
	pushl $number_of_recs
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl first_arg(%ebp)
	calll get_file_size
	addl $0x4, %esp

	subl $HEADER_SIZE, %eax

	xorl %edx, %edx
	movl $STRUCT_SIZE, %ecx

	idivl %ecx

	pushl %eax
	calll printl
	addl $0x4, %esp

	pushl $'\n'
	calll lputchar
	addl $0x4, %esp

	calll prt_ln

	pushl $len_header
	pushl $header
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	# Main part
	pushl $SEEK_SET
	pushl $HEADER_SIZE
	pushl first_arg(%ebp)
	calll lseek
	addl $0xC, %esp

show_recs_loop:
	# Reading values
	pushl $STRUCT_SIZE
	leal struct_1(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	calll read
	addl $0xC, %esp

	testl %eax, %eax
	jz show_recs_loop_end
	js show_recs_loop_end

	# Printing values
	pushl $'|'
	calll lputchar
	addl $0x4, %esp

	pushl struct_1 + iD(%ebp)
	calll numlen
	addl $0x4, %esp

	subl $0x8, %eax
	negl %eax

show_recs_loop_print_spaces_id:
	testl %eax, %eax
	jz show_recs_loop_print_spaces_id_end

	# Saving registers
	pushl %eax

	pushl $' '
	calll lputchar
	addl $0x4, %esp

	# Restoring registers
	popl %eax

	decl %eax

	jmp show_recs_loop_print_spaces_id

show_recs_loop_print_spaces_id_end:
	pushl struct_1 + iD(%ebp)
	calll printl
	addl $0x4, %esp

	calll print_vert_line

	pushl $NAME_SIZE
	leal struct_1 + NAME(%ebp), %eax
	pushl %eax
	pushl $STDOUT
	calll write
	addl $0xC, %esp

show_recs_loop_check_letters:
	leal struct_1 + NAME(%ebp), %eax
	pushl %eax
	calll lstrlen
	addl $0x4, %esp

	subl $NAME_SIZE, %eax
	negl %eax
	subl $0x2, %eax

show_recs_loop_print_spaces:
	testl %eax, %eax
	jz show_recs_loop_print_spaces_end

	# Saving registers
	pushl %eax

	pushl $' '
	calll lputchar
	addl $0x4, %esp

	# Restoring registers
	popl %eax

	decl %eax

	jmp show_recs_loop_print_spaces

show_recs_loop_print_spaces_end:
	calll print_vert_line

	pushl struct_1 + YEAR(%ebp)
	calll printl
	addl $0x4, %esp

	calll print_vert_line

	pushl $'\t'
	calll lputchar
	addl $0x4, %esp

	pushl struct_1 + QUANT(%ebp)
	calll printl
	addl $0x4, %esp

	pushl $' '
	calll lputchar
	addl $0x4, %esp

	movl struct_1 + QUANT(%ebp), %eax
	xorl %edx, %edx
	movl $0xA, %ecx

	idivl %ecx

	testl %eax, %eax
	jnz show_recs_continue

	pushl $' '
	calll lputchar
	addl $0x4, %esp

show_recs_continue:
	calll print_vert_line

	cmpb $0x0, struct_1 + FLAG(%ebp)
	jne show_recs_print_yes

	pushl $len_no
	pushl $no

	jmp show_recs_print_fin

show_recs_print_yes:
	pushl $len_yes
	pushl $yes

show_recs_print_fin:
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

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
	calll lseek
	addl $0xC, %esp

	pushl $sizeof_int
	leal st_gr + iD(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	calll read
	addl $0xC, %esp

	pushl $SEEK_END
	pushl $0x0
	pushl first_arg(%ebp)
	calll lseek
	addl $0xC, %esp

add_records_read:
	incl st_gr + iD(%ebp)

add_records_read_do_while_0:
	pushl $len_add_type_name
	pushl $add_type_name
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $NAME_SIZE
	leal st_gr + NAME(%ebp), %eax
	pushl %eax
	pushl $STDIN
	calll read
	addl $0xC, %esp

	cmpl $NAME_SIZE - 1, %eax
	jle add_records_read_do_while_0_end

	calll prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp add_records_read_do_while_0

add_records_read_do_while_0_end:
	movb $0x0, st_gr + NAME - 1(%ebp, %eax)

add_records_read_do_while_1:
	pushl $len_add_type_year
	pushl $add_type_year
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, ADD_REC_BUF - 1(%eax)

	cmpl $YEAR_MAX_LEN, %eax
	jnz add_records_read_do_while_1_err

	pushl $ADD_REC_BUF
	calll check_number
	addl $0x4, %esp

	testl %eax, %eax
	jnz add_records_read_do_while_1_end

add_records_read_do_while_1_err:
	calll prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp add_records_read_do_while_1

add_records_read_do_while_1_end:
	pushl $ADD_REC_BUF
	calll atoi
	addl $0x4, %esp

	testl %eax, %eax
	jz add_records_read_do_while_1_err
	js add_records_read_do_while_1_err

	movl %eax, st_gr + YEAR(%ebp)

add_records_read_do_while_2:
	pushl $len_add_type_number
	pushl $add_type_number
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, ADD_REC_BUF - 1(%eax)

	cmpl $GR_SIZE_MAX_LEN, %eax
	jg add_records_read_do_while_2_err

	pushl $ADD_REC_BUF
	calll check_number
	addl $0x4, %esp

	testl %eax, %eax
	jnz add_records_read_do_while_2_end

add_records_read_do_while_2_err:
	calll prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp add_records_read_do_while_2

add_records_read_do_while_2_end:
	pushl $ADD_REC_BUF
	calll atoi
	addl $0x4, %esp

	testl %eax, %eax
	jz add_records_read_do_while_2_err
	js add_records_read_do_while_2_err

	movl %eax, st_gr + QUANT(%ebp)

	pushl $len_add_type_grad
	pushl $add_type_grad
	calll prompt_yn
	addl $0x8, %esp

	movb %al, st_gr + FLAG(%ebp)

	pushl $STRUCT_SIZE
	leal st_gr(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	calll prt_ln

	pushl $len_add_more_records
	pushl $add_more_records
	calll prompt_yn
	addl $0x8, %esp

	testl %eax, %eax
	jz add_records_read_end

	calll prt_ln

	jmp add_records_read

add_records_read_end:
	pushl st_gr + iD(%ebp)
	pushl first_arg(%ebp)
	calll fix_last_id
	addl $0x8, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

# void fix_last_id(int fd, int id);
.type fix_last_id, @function
fix_last_id:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	pushl $SEEK_SET
	pushl $sizeof_int
	pushl first_arg(%ebp)
	calll lseek
	addl $0xC, %esp

	pushl $sizeof_int
	leal second_arg(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	calll write
	addl $0xC, %esp

	# TODO: is this needed?
	pushl first_arg(%ebp)
	calll lrewind
	addl $0x4, %esp

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
	calll write
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
	.equ curr_id, -12 # ID that user typed in
	.equ last_id, -16 # Last possible ID in this file
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
	calll get_file_size
	addl $0x4, %esp

	movl %eax, file_size(%ebp)

	# Syscall
	pushl $0x0
	pushl first_arg(%ebp)
	pushl $MAP_SHARE
	pushl $PROT_RDWR
	pushl file_size(%ebp)
	pushl $0x0
	movl %esp, %ebx
	movl $SYS_MMAP, %eax
	int $0x80 # 0x80's interrupt
	addl $0x18, %esp

	movl %eax, mappedfile(%ebp)

edit_record_do_while_1:
	pushl $len_edit_type_number
	pushl $edit_type_number
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, ADD_REC_BUF - 1(%eax)

	cmpl $INT_MAX_LEN, %eax
	jle edit_record_do_while_1_end

	calll prt_ln

	pushl $len_edit_invalid_id
	pushl $edit_invalid_id
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp edit_record_do_while_1

edit_record_do_while_1_end:
	calll prt_ln

	pushl $ADD_REC_BUF
	calll atoi
	addl $0x4, %esp

	movl %eax, curr_id(%ebp)

	movl mappedfile(%ebp), %ebx
	addl $sizeof_int, %ebx
	movl (%ebx), %ecx
	movl %ecx, last_id(%ebp)

	cmpl %ecx, curr_id(%ebp)
	jg edit_record_search_for_id_error

	movl curr_id(%ebp), %ecx
	movl last_id(%ebp), %edx

edit_record_search_for_id:
	cmpl %ecx, iD(%ebx)
	je edit_record_search_for_id_found

	cmpl %edx, iD(%ebx)
	je edit_record_search_for_id_error

	addl $STRUCT_SIZE, %ebx

	jmp edit_record_search_for_id

edit_record_search_for_id_error:
	pushl $len_edit_invalid_id
	pushl $edit_invalid_id
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	pushl $len_edit_retype_number
	pushl $edit_retype_number
	calll prompt_yn
	addl $0x8, %esp

	# Saving registers
	pushl %eax

	calll prt_ln

	# Restoring registers
	popl %eax

	testl %eax, %eax
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
	calll write
	addl $0xC, %esp

	pushl $NAME_SIZE
	leal ed_stGr + NAME(%ebp), %eax
	pushl %eax
	pushl $STDIN
	calll read
	addl $0xC, %esp

	cmpl $NAME_SIZE - 1, %eax
	jle edit_records_read_do_while_0_end

	calll prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp edit_records_read_do_while_0

edit_records_read_do_while_0_end:
	movb $0x0, ed_stGr + NAME - 1(%ebp, %eax)

edit_records_read_do_while_1:
	pushl $len_add_type_year
	pushl $add_type_year
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, ADD_REC_BUF - 1(%eax)

	cmpl $YEAR_MAX_LEN, %eax
	jnz edit_records_read_do_while_1_err

	pushl $ADD_REC_BUF
	calll check_number
	addl $0x4, %esp

	testl %eax, %eax
	jnz edit_records_read_do_while_1_end

edit_records_read_do_while_1_err:
	calll prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp edit_records_read_do_while_1

edit_records_read_do_while_1_end:
	pushl $ADD_REC_BUF
	calll atoi
	addl $0x4, %esp

	testl %eax, %eax
	jz edit_records_read_do_while_1_err
	js edit_records_read_do_while_1_err

	movl %eax, ed_stGr + YEAR(%ebp)

edit_records_read_do_while_2:
	pushl $len_add_type_number
	pushl $add_type_number
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, ADD_REC_BUF - 1(%eax)

	cmpl $GR_SIZE_MAX_LEN, %eax
	jg edit_records_read_do_while_2_err

	pushl $ADD_REC_BUF
	calll check_number
	addl $0x4, %esp

	testl %eax, %eax
	jnz edit_records_read_do_while_2_end

edit_records_read_do_while_2_err:
	calll prt_ln

	pushl $len_add_invalid
	pushl $add_invalid
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp edit_records_read_do_while_2

edit_records_read_do_while_2_end:
	pushl $ADD_REC_BUF
	calll atoi
	addl $0x4, %esp

	testl %eax, %eax
	jz edit_records_read_do_while_2_err
	js edit_records_read_do_while_2_err

	movl %eax, ed_stGr + QUANT(%ebp)

	pushl $len_add_type_grad
	pushl $add_type_grad
	calll prompt_yn
	addl $0x8, %esp

	movb %al, ed_stGr + FLAG(%ebp)

	calll prt_ln

	pushl $len_edit_more_records
	pushl $edit_more_records
	calll prompt_yn
	addl $0x8, %esp

	testl %eax, %eax
	jz edit_record_exit

	calll prt_ln

	jmp edit_record_do_while_1

edit_record_exit:
	pushl $STRUCT_SIZE
	leal ed_stGr(%ebp), %eax
	pushl %eax
	pushl curr_mfile_pos(%ebp)
	calll lmemcpy
	addl $0xC, %esp

	# Syscall
	movl file_size(%ebp), %ecx
	movl mappedfile(%ebp), %ebx
	movl $SYS_MUNMAP, %eax
	int $0x80 # 0x80's interrupt

	# TODO: is that needed?
	pushl first_arg(%ebp)
	calll lrewind
	addl $0x4, %esp

	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.globl delete_record
.type delete_record, @function
.equ SYS_FTRUNCATE, 93
delete_record:
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

	.equ nrecs_del, curr_mfile_pos - sizeof_int
	subl $sizeof_int, %esp

	# Saving registers
	pushl %ebx

	# Initializing variables
	movl $0x0, ed_stGr + iD(%ebp)
	movl $0x0, ed_stGr + NAME(%ebp)
	movl $0x0, ed_stGr + NAME + sizeof_int(%ebp)
	movl $0x0, nrecs_del(%ebp)
	
	# Main part	
	pushl first_arg(%ebp)
	calll get_file_size
	addl $0x4, %esp

	movl %eax, file_size(%ebp)

	# Syscall
	pushl $0x0
	pushl first_arg(%ebp)
	pushl $MAP_SHARE
	pushl $PROT_RDWR
	pushl file_size(%ebp)
	pushl $0x0
	movl %esp, %ebx
	movl $SYS_MMAP, %eax
	int $0x80 # 0x80's interrupt
	addl $0x18, %esp

	movl %eax, mappedfile(%ebp)

delete_record_do_while_1:
	pushl $len_delete_type_number
	pushl $delete_type_number
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $ADD_REC_LEN
	pushl $ADD_REC_BUF
	pushl $STDIN
	calll read
	addl $0xC, %esp

	movb $0x0, ADD_REC_BUF - 1(%eax)

	cmpl $INT_MAX_LEN, %eax
	jle delete_record_do_while_1_end

	calll prt_ln

	pushl $len_edit_invalid_id
	pushl $edit_invalid_id
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	jmp delete_record_do_while_1

delete_record_do_while_1_end:
	calll prt_ln

	pushl $ADD_REC_BUF
	calll atoi
	addl $0x4, %esp

	movl %eax, curr_id(%ebp)

	movl mappedfile(%ebp), %ebx
	addl $HEADER_SIZE, %ebx
	movl -sizeof_int(%ebx), %ecx
	movl %ecx, last_id(%ebp)

	cmpl %ecx, curr_id(%ebp)
	jg delete_record_search_for_id_error

	movl curr_id(%ebp), %ecx
	movl last_id(%ebp), %edx

delete_record_search_for_id:
	cmpl %ecx, iD(%ebx)
	jz delete_record_search_for_id_found

	cmpl %edx, iD(%ebx)
	jz delete_record_search_for_id_error

	addl $STRUCT_SIZE, %ebx

	jmp delete_record_search_for_id

delete_record_search_for_id_error:
	pushl $len_edit_invalid_id
	pushl $edit_invalid_id
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	pushl $len_edit_retype_number
	pushl $edit_retype_number
	calll prompt_yn
	addl $0x8, %esp

	# Saving registers
	pushl %eax

	calll prt_ln

	# Restoring registers
	popl %eax

	testl %eax, %eax
	jz delete_record_exit

	jmp delete_record_do_while_1

delete_record_search_for_id_found:
	# Deleting record
	movl curr_id(%ebp), %ecx
	cmpl %ecx, last_id(%ebp)
	je delete_record_ask

	addl $STRUCT_SIZE, %ebx
	movl %ebx, curr_mfile_pos(%ebp) # store current position in file (i.e. address in mmaped file)

	subl mappedfile(%ebp), %ebx # get length of chunk that is before removed record
	subl file_size(%ebp), %ebx # get negative length of chunk that is after the record
	negl %ebx

	# Remove one record (by overwriting it)
	pushl %ebx
	pushl curr_mfile_pos(%ebp)
	subl $STRUCT_SIZE, curr_mfile_pos(%ebp)
	pushl curr_mfile_pos(%ebp)
	calll lmemcpy
	addl $0xC, %esp

delete_record_ask:
	addl $0x1, nrecs_del(%ebp)

	pushl $len_delete_success
	pushl $delete_success
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	pushl $len_delete_more_records
	pushl $delete_more_records
	calll prompt_yn
	addl $0x8, %esp

	# Saving registers
	pushl %eax

	calll prt_ln
	
	# Restoring registers
	popl %eax

	testl %eax, %eax
	jnz delete_record_do_while_1

delete_record_exit:
	# Syscall
	movl file_size(%ebp), %ecx
	movl mappedfile(%ebp), %ebx
	movl $SYS_MUNMAP, %eax
	int $0x80 # 0x80's interrupt

	pushl first_arg(%ebp)
	calll lrewind
	addl $0x4, %esp

delete_record_if:
	cmpl $0x0, nrecs_del(%ebp)
	je delete_record_exit_2

delete_record_exit_1:
	# We need to truncate the file, after records were removed
	movl nrecs_del(%ebp), %eax
	imull $STRUCT_SIZE, %eax
	subl %eax, file_size(%ebp)

	# Syscall
	movl $SYS_FTRUNCATE, %eax
	movl first_arg(%ebp), %ebx
	movl file_size(%ebp), %ecx
	int $0x80 # 0x80's interrupt

delete_record_exit_2:
	# Restoring registers
	popl %ebx

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

# Checks and fixes the autoincrement ID
.globl checking_integrity
.type checking_integrity, @function
checking_integrity:
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp
	.equ auto_id, -4
	.equ llast_id, -8
	subl $0x8, %esp # Acquiring space for two variables

	# Main part
	pushl $len_checking_check
	pushl $checking_check
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	pushl $SEEK_SET
	pushl $sizeof_int
	pushl first_arg(%ebp)
	calll lseek
	addl $0xC, %esp

	pushl $sizeof_int
	leal auto_id(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	calll read
	addl $0xC, %esp

	pushl $SEEK_END
	pushl $-STRUCT_SIZE
	pushl first_arg(%ebp)
	calll lseek
	addl $0xC, %esp

	pushl $sizeof_int
	leal llast_id(%ebp), %eax
	pushl %eax
	pushl first_arg(%ebp)
	calll read
	addl $0xC, %esp

	movl auto_id(%ebp), %eax

	cmpl %eax, llast_id(%ebp) # if (last <= auto)
	jle checking_integrity_ok

checking_integrity_fail:
	pushl $len_checking_fail
	pushl $checking_fail
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	calll prt_ln

	pushl llast_id(%ebp)
	pushl first_arg(%ebp)
	calll fix_last_id
	addl $0x8, %esp

	pushl $len_checking_fix
	pushl $checking_fix
	pushl $STDOUT
	calll write
	addl $0xC, %esp

	jmp checking_integrity_exit

checking_integrity_ok:
	pushl $len_checking_ok
	pushl $checking_ok
	pushl $STDOUT
	calll write
	addl $0xC, %esp

checking_integrity_exit:
	calll prt_ln

	pushl first_arg(%ebp)
	calll lrewind
	addl $0x4, %esp

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	retl

.equ STRUCT_SIZE, 19
.equ NAME_SIZE, 6
.equ YEAR_SIZE, 4
.equ NUM_OF_ST_SIZE, 8
.equ FLAG_SIZE, 1

.section .data
header:
	.ascii "| GROUP NAME | YEAR | #OF_ST. | GRAD |\0"
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


.section .text
.globl show_recs
show_recs:
	# Initializing functions stack frame
	pushl %ebp
	movl %esp, %ebp
	subl $STRUCT_SIZE, %esp # Acquiring space for struct

	# Initializing variables
	movl 8(%ebp), %eax

	# I/O flow 


show_recs_loop:
	# Main part

	pushl $STRUCT_SIZE
	pushl -4(%ebp)
	pushl %eax
	call read




	cmpl $0x0, %eax
	jne show_recs_loop

show_recs_loop_end:

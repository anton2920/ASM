# Macros
.equ SYS_BRK, 45
.equ HEADER_FULL_SIZE, 8
.equ HD_SIZE_OFFSET, 4
.equ HD_FLAG_OFFSET, 0

.equ AVAIL, 1
.equ UNAVAIL, 0

# Global variables
.section .data
heap_begin:
    .long 0
current_break:
    .long 0

.section .text
.globl alloc_init
.type alloc_init, @function
alloc_init:
    # Initializing function's stack frame
    pushl %ebp
    movl %esp, %ebp
    
    # Main part
    movl $SYS_BRK, %eax # BRK syscall
    movl $0x0, %ebx # We want to know current position
    int $0x80 # 0x80's interrupt

    incl %eax # Gets the first invalid address
    movl %eax, heap_begin # Store useful data
    movl %eax, current_break # in our global variables

    # Destroying function's stack frame
    movl %ebp, %esp
    popl %ebp
    ret

.globl allocate
.type allocate, @function
allocate: 
	# Initializing function's stack frame
	pushl %ebp
	movl %esp, %ebp

	# Initializing variables
	movl 8(%ebp), %ecx # Requested size
	movl heap_begin, %eax # Beggining of the heap
	movl current_break, %ebx # Current position

	# Main part
allocate_loop_begin:
	cmpl %ebx, %eax # if (beg == curr)
	je alloc_get_more # Request memory from linux via syscall

	movl HD_SIZE_OFFSET(%ebx), %edx # Memory of the current block

	cmpl $UNAVAIL, HD_FLAG_OFFSET(%ebx) # if (flag == 0)
	je alloc_next_pos # Go to the next block

	cmpl %edx, %ecx # if (size == requested)
	jle alloc_here # Allocate memory in this block

alloc_get_more:
	addl $HEADER_FULL_SIZE, %ebx # Adding 8 to current position
	addl %ecx, %ebx # Adding requested to current position

	pushl %eax # Saving
	pushl %ecx # our 
	pushl %ebx # registers
	movl $SYS_BRK, %eax # BRK syscall
	int $0x80 # 0x80's interrupt

	cmpl $0x0, %eax
	je alloc_error

	popl %ebx # Restoring
	popl %ecx # our
	popl %eax # registers

	movl $UNAVAIL, HD_FLAG_OFFSET(%eax) # This block of memory is unavailable now
	movl %ecx, HD_SIZE_OFFSET(%eax) # It's size equals to requested

	addl $HEADER_FULL_SIZE, %eax # Heap now starts at usable memory (8 bytes forward)
	movl %ebx, current_break # Current break is now right after our block

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

alloc_error:
	movl $0x0, %eax # Return zero as error code

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

alloc_next_pos:
	addl $HEADER_FULL_SIZE, %eax # Heap is 8 bytes forward now
	addl %edx, %eax # Heap is now one block forward now
	jmp allocate_loop_begin # Go to start

alloc_here:
	movl $UNAVAIL, HD_FLAG_OFFSET(%eax) # This block of memory is unavailable now
	addl $HEADER_FULL_SIZE, %eax # Heap now starts at needed position

	# Destroying function's stack frame
	movl %ebp, %esp
	popl %ebp
	ret

.globl deallocate
.type deallocate, @function
.equ MEM_REG, 4
deallocate:
	# Initializing variables
	movl MEM_REG(%esp), %eax

	# Main part
	subl $HEADER_FULL_SIZE, %eax
	movl $AVAIL, HD_FLAG_OFFSET(%eax)

	# Returning (nothing)
	ret

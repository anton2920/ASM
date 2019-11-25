	.file	"kernel.c"
	.text
	.p2align 4,,15
	.globl	vga_entry
	.type	vga_entry, @function
vga_entry:
.LFB0:
	.cfi_startproc
	movzbl	12(%esp), %eax
	movzbl	4(%esp), %edx
	sall	$4, %eax
	orb	8(%esp), %al
	sall	$8, %eax
	orl	%edx, %eax
	ret
	.cfi_endproc
.LFE0:
	.size	vga_entry, .-vga_entry
	.p2align 4,,15
	.globl	clear_vga_buffer
	.type	clear_vga_buffer, @function
clear_vga_buffer:
.LFB1:
	.cfi_startproc
	movl	4(%esp), %eax
	movzbl	12(%esp), %edx
	movl	(%eax), %eax
	sall	$4, %edx
	orb	8(%esp), %dl
	sall	$8, %edx
	leal	4400(%eax), %ecx
	.p2align 4,,10
	.p2align 3
.L4:
	movw	%dx, (%eax)
	addl	$2, %eax
	cmpl	%ecx, %eax
	jne	.L4
	ret
	.cfi_endproc
.LFE1:
	.size	clear_vga_buffer, .-clear_vga_buffer
	.p2align 4,,15
	.globl	init_vga
	.type	init_vga, @function
init_vga:
.LFB2:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movzbl	8(%esp), %edx
	sall	$4, %edx
	orb	4(%esp), %dl
	sall	$8, %edx
	movl	vga_buffer@GOT(%eax), %eax
	movl	$753664, (%eax)
	movl	$753664, %eax
	.p2align 4,,10
	.p2align 3
.L7:
	movw	%dx, (%eax)
	addl	$2, %eax
	cmpl	$758064, %eax
	jne	.L7
	ret
	.cfi_endproc
.LFE2:
	.size	init_vga, .-init_vga
	.p2align 4,,15
	.globl	kernel_entry
	.type	kernel_entry, @function
kernel_entry:
.LFB3:
	.cfi_startproc
	call	__x86.get_pc_thunk.ax
	addl	$_GLOBAL_OFFSET_TABLE_, %eax
	movl	vga_buffer@GOT(%eax), %eax
	movl	$753664, (%eax)
	movl	$753664, %eax
	.p2align 4,,10
	.p2align 3
.L10:
	movl	$3840, %edx
	addl	$2, %eax
	movw	%dx, -2(%eax)
	cmpl	$758064, %eax
	jne	.L10
	movl	$258281288, 753664
	movl	$3940, %eax
	movl	$258740076, 753668
	movl	$253759343, 753672
	movl	$258936663, 753676
	movl	$258740082, 753680
	movw	%ax, 753684
	ret
	.cfi_endproc
.LFE3:
	.size	kernel_entry, .-kernel_entry
	.comm	vga_buffer,4,4
	.section	.text.__x86.get_pc_thunk.ax,"axG",@progbits,__x86.get_pc_thunk.ax,comdat
	.globl	__x86.get_pc_thunk.ax
	.hidden	__x86.get_pc_thunk.ax
	.type	__x86.get_pc_thunk.ax, @function
__x86.get_pc_thunk.ax:
.LFB4:
	.cfi_startproc
	movl	(%esp), %eax
	ret
	.cfi_endproc
.LFE4:
	.ident	"GCC: (Debian 8.3.0-6) 8.3.0"
	.section	.note.GNU-stack,"",@progbits

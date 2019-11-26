#include <stdio.h>
#include <stddef.h>

typedef struct __attribute__ ((packed)) {
    unsigned short di, si, bp, sp, bx, dx, cx, ax;
    unsigned short gs, fs, es, ds, eflags;
} regs16_t;

main() {

	/* I/O flow */
	printf("Size: %lu, AX: %lu, CX: %lu, DX: %lu\n", sizeof(regs16_t), offsetof(regs16_t, ax), offsetof(regs16_t, cx), offsetof(regs16_t, dx));
}
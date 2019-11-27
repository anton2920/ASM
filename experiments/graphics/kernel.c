#define DELAY_VALUE 2000

static int rand_seed = 12345;

/* New datatypes */
enum rand_consts {
	a = 1103515245,
	c = 12345,
	m = 0x7FFFFFFF
};

typedef struct __attribute__ ((packed)) {
    unsigned short di, si, bp, sp, bx, dx, cx, ax;
    unsigned short gs, fs, es, ds, eflags;
} regs16_t;

/* Functions' declarations */
void vga_mode_on(void);
void vga_mode_off(void);
int rand(void);
void perform_delay(int);
void draw_dot(int, int, char);
int get_next_key_code_if_ready(void);
 
extern void int32(unsigned char intnum, regs16_t *regs);

void kernel_entry(void) {

	/* Initializing variables */
	auto int x, y;
	auto char clr;
	auto char key;
	auto regs16_t r;

	/* Main part */
	vga_mode_on();

	for ( ;; ) {
		x = rand() % 320;
		y = rand() % 240;
		clr = rand() % 256;

		draw_dot(x, y, clr);

		perform_delay(DELAY_VALUE);
		
		if ((key = get_next_key_code_if_ready()) == 0x39) {
			break;
		}
	}

	vga_mode_off();
}

void vga_mode_on(void) {

	/* Initializing variables */
	auto regs16_t r;
	r.ax = 0x0013;

	/* Main part */
	/*__asm__ __volatile__ (
		"xorl %eax, %eax\n\t"
		"movb $0x13, %al\n\t"
		"int $0x10"
	);*/

	int32(0x10, &r);
}

void vga_mode_off(void) {

	/* Initializing variables */
	auto regs16_t r;
	r.ax = 0x0003;

	/* Main part */
	/*__asm__ __volatile__ (
		"xorl %eax, %eax\n\t"
		"movb $0x03, %al\n\t"
		"int $0x10\n"
	);*/

	int32(0x10, &r);
}

int rand(void) {

	/* Initializing variables */
	extern int rand_seed;

	/* Main part */
	rand_seed = (a * rand_seed + c) % m;

	/* Returning value */
	return rand_seed;
}

void perform_delay(int val) {

	/* Initializing variables */
	auto int delay;

	/* Main part */
	for (delay = val; delay > 0; --delay) {
		__asm__ __volatile__ ("nop");
	}
}

void draw_dot(int x, int y, char clr) {

	/* Initializing variables */
	static unsigned char *vga_buffer = (unsigned char *) 0xA0000;
	auto int offset = (y << 8) + (y << 6) + x;

	/* Main part */
	/*__asm__ __volatile__ (
		"int $0x10"
		:
		: "a" (clr), "c" (x), "d" (y)
	);*/
	vga_buffer[offset] = clr;
}

int get_next_key_code_if_ready(void) {

	/* Initializing variables */
	/* int key; */
	auto regs16_t r;
	r.ax = 0x0100;

	/* Main part */
	/*__asm__ __volatile__ (
		"xorl %%eax, %%eax\n\t"
		"movb $0x1, %%ah\n\t"
		"int $0x16\n\t"
		: "=a" (key)
	);*/

	int32(0x16, &r);

	/* Returning value */
	/* return key; */
	return r.ax;
}
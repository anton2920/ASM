#define DELAY_VALUE 1000

static int rand_seed = 12345;

enum rand_consts {
	a = 1103515245,
	c = 12345,
	m = 0x7FFFFFFF
};

void vga_mode_on(void);
void vga_mode_off(void);
int rand(void);
void perform_delay(void);
void draw_dot(int, int, char);
int get_next_key_code_if_ready(void);

void kernel_entry(void) {

	/* Initializing variables */
	int x, y;
	char clr;
	char key;

	/* Main part */
	for ( ;; ) {
		x = rand() % 320;
		y = rand() % 240;
		clr = rand() % 256;

		draw_dot(x, y, clr);

		perform_delay();
		
		if ((key = get_next_key_code_if_ready()) == 0x39) {
			break;
		}
	}
}

/*void vga_mode_on(void) {

	Main part
	__asm__ __volatile__ (
		"xorl %eax, %eax\n\t"
		"movb $0x13, %al\n\t"
		"int $0x10"
	);
}*/

/*void vga_mode_off(void) {

	Main part 
	__asm__ __volatile__ (
		"xorl %eax, %eax\n\t"
		"movb $0x03, %al\n\t"
		"int $0x10\n"
	);
}*/

int rand(void) {

	/* Initializing variables */
	extern int rand_seed;

	/* Main part */
	rand_seed = (a * rand_seed + c) % m;

	/* Returning value */
	return rand_seed;
}

void perform_delay(void) {

	/* Initializing variables */
	int delay;

	/* Main part */
	for (delay = DELAY_VALUE; delay > 0; --delay) {
		__asm__ __volatile__ ("nop");
	}
}

void draw_dot(int x, int y, char clr) {

	/* Initializing variables */
	static unsigned char *vga_buffer = (unsigned char *) 0xA0000;
	int offset = (y << 8) + (y << 6) + x;

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
	int key;

	/* Main part */
	__asm__ __volatile__ (
		"xorl %%eax, %%eax\n\t"
		"movb $0x1, %%ah\n\t"
		"int $0x16\n\t"
		: "=a" (key)
	);

	/* Returning value */
	return key;
}

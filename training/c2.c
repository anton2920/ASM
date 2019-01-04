#include <stdio.h>
#include <zconf.h>


extern int sum(int, int);
extern int agetchar(void);

main() {

	/* Initializing variables */
	int a, b;

	write(1, "Type a: ", sizeof("Type a: ") - 1);
	a = agetchar() - '0';
    write(1, "Type b: ", sizeof("Type b: ") - 1);
    b = agetchar() - '0';
	printf("a + b = %d\n", sum(a, b));
}
#include <stdio.h>

extern int sum(int, int);

main() {

	/* Initializing variables */
	int a, b;

	printf("Type a: ");
	scanf("%d", &a);
	printf("Type b: ");
	scanf("%d", &b);
	printf("a + b = %d\n", sum(a, b));
}
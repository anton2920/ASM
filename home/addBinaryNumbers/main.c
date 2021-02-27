#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main() {

	/* Initializing variables */
	char *c = "xxxx";

	/* Main part */
	addBinaryNumbers("1000", "111", c);

	if (!strcmp(c, "1111")) {
		printf("Correct\n");
	} else {
		printf("Incorrect\n");
	}
}
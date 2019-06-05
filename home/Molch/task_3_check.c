#include <stdio.h>
#include <math.h>

double f(double);

main() {

	/* Initializing variables */
	auto double i;

	for (i = -1.0; i <= 1.0; i += 0.1) {
		printf("%.1lf\t%lf\n", i, f(i));
	}
}

double f(double x) {

	/* Returning value */
	return sin(x) + cos(x / 2) * x;
}
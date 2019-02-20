#include <stdio.h>

int sum_of_elem(char **, int);
extern int latoi(const char *);

main(int argc, char *argv[]) {

    /* Initializing variables */
    char **p;
    int c, a;

    /* Main part */
    c = argc - 1;
    p = argv + 1;

    /* Sum of elements */
    printf("Sum of the elements equals to ");
    a = sum_of_elem(p, c);
    printf("%d\n", a);
}

int sum_of_elem(char *a[], int b) {

    /* Initializing variables */
    int d; /* sum */

    /* Main part */
    for (d = 0, --b; b >= 0; --b) {
        d += latoi(*(a + b));
    }

    /* Returning value */
    return d;
}
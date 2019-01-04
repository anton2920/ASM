#include <stdio.h>

extern int power(int, int);

main() {

    /* Initializing variables */
    int base, pow, ans;

    /* I/O flow && VarCheck */
    printf("Type base: ");
    scanf("%d", &base);
    do {
        printf("Type power: ");
        scanf("%d", &pow);
    } while (pow < 0);

    /* Main part */
    ans = power(base, pow);
    /* pushl pow
     * pushl base
     * call power
     */

    /* Final output */
    printf("%d^%d = %d\n", base, pow, ans);
}
#include <stdio.h>
#include <string.h>

/* Macros */
#define KIB (1024)

/* Assembly functions */
extern void alloc_init(void);
extern void *allocate(int);
extern void deallocate(void *);

/* Function declarations */
char *lstrdup(char *);

main() {

    /* Initializing variables */
    char *p, str[KIB];

    /* I/O flow */
    printf("Type string: ");
    fgets(str, KIB, stdin);

    /* Main part */
    p = lstrdup(str);

    /* Final output */
    if (p) {
        printf("Duplicated string: %s\n", p);
    }

    /* Deallocating memory */
    deallocate(p);
}

char *lstrdup(char *str) {

    /* Initializing variables */
    char *p = NULL;
    int len;

    /* Initializing an imaginary (1f31a) memory manager */
    alloc_init();

    /* Main part */
    if ((len = strlen(str))) {
        p = (char *) allocate(len);
        if (p) {
            strcpy(p, str);
        }
    }

    /* Returning value */
    return p;
}
#define NAME (21)
#define KIB (1024)
#define O_RDONLY (0)
#define STD_PERMS (0666)

extern int awrite(int, char *, int);
extern int aread(int, char *, int);
extern int aopen(char *, int, int);
extern int aclose(int);
/* extern int make_file_name(char *, int); */

main() {

    /* Initializing variables */
    char name[NAME], data[KIB];
    int fd, n;

    /* I/O flow */
    awrite(1, "Type filename: ", sizeof("Type filename: ") - 1);
    n = aread(0, name, 21);
    /* make_file_name(name, 21); */
    *(name + (n - 1)) = '\0';

    if ((fd = aopen(name, O_RDONLY, STD_PERMS)) > 0) {
        n = aread(fd, data, sizeof(data));
        aclose(fd);
        awrite(1, data, n);
    } else {
        awrite(2, "Error!\n", sizeof("Error!\n") - 1);
    }
}
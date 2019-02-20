int latoi(const char *b) {

    /* Initializing variables */
    int a = 0, c;
    char d;

    /* Main part */
    for (c = 0; *(b + c); ++c) {
        d = *(b + c);
        d -= '0';
        a *= 0xA;
        a += d;
    }

    /* Returning value */
    return a;
}
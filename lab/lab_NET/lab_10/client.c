#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

#include <zconf.h>

#include <string.h>

#define handle_error(msg)   \
    do {                    \
        perror(msg);        \
        exit(EXIT_FAILURE); \
    } while (0)

#define sizeof_buffer (4096)

void *get_messages(void *arg) {

    /* Initializing variables */
    auto char buffer[sizeof_buffer] = {};
    auto int sockfd = *((int *) arg);
    auto size_t n;

    /* Main part */
    for ( ;; ) {
        if ((n = read(sockfd, buffer, sizeof_buffer)) < 0) {
            handle_error("read");
        }
        if (write(1, buffer, n) < 0) {
            handle_error("write");
        }

        if (!strcmp(buffer, "Bye!\n") ||
                !strcmp(buffer, "Server is shutting down...\n")) {
            break;
        }
    }

    /* Returning value */
    return NULL;
}

void *send_messages(void *arg) {

    /* Initializing variables */
    auto char buffer[sizeof_buffer] = {};
    auto int sockfd = *((int *) arg);
    auto size_t n;

    /* Main part */
    for ( ;; ) {
        if ((n = read(0, buffer, sizeof_buffer)) < 0) {
            handle_error("read");
        }
        if (write(sockfd, buffer, n) < 0) {
            handle_error("write");
        }

        if (!strcmp(buffer, "quit\n") || !strcmp(buffer, "shutdown\n")) {
            break;
        }
    }

    /* Returning value */
    return NULL;
}

int main(int argc, char *argv[]) {

    /* Initializing variables */
    auto int sockfd, portno;

    auto struct sockaddr_in serv_addr = {};
    auto struct hostent *server;

    /* VarCheck */
    if (argc < 3) {
        fprintf(stderr, "usage: %s hostname port\n", argv[0]);
        exit(0);
    }

    /* Main part */
    portno = atoi(argv[2]);
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        handle_error("socket");
    }

    server = gethostbyname(argv[1]);
    if (server == NULL) {
        fprintf(stderr, "gethostbyname");
        exit(0);
    }

    serv_addr.sin_family = AF_INET;
    serv_addr.sin_port = htons(portno);
    bcopy((char *) server->h_addr, (char *) &serv_addr.sin_addr.s_addr, server->h_length);

    if (connect(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) {
        handle_error("connect");
    }

    /* Let's go with threads */
    auto pthread_t recv_t, send_t;

    if (pthread_create(&recv_t, NULL, get_messages, &sockfd)) {
        handle_error("pthread");
    }
    if (pthread_create(&send_t, NULL, send_messages, &sockfd)) {
        handle_error("pthread");
    }

    pthread_join(recv_t, 0);
    pthread_join(send_t, 0);

    /* Returning value */
    return 0;
}
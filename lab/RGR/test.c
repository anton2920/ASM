#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>

main() {

	auto char a[20];

	printf("Type pass: ");
	system("stty -echo");
	scanf("%20s", a);

	printf("Type pass: ");
	system("stty echo");
	scanf("%20s", a);
}
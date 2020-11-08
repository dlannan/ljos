#include <stdio.h>
#include <unistd.h>

int main() {

	FILE *fd = fopen("init.txt", "w");
	fprintf( fd, "%s \n", "Test" );
	fclose( fd );
	while(1) {
		printf("Hello...\n");
		sleep(1);
	}
	return 0;
}

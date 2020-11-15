#include <assert.h>
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/select.h>

int getch_blocking() {
	int ch;
	struct termios oldt, newt;
	tcgetattr ( STDIN_FILENO, &oldt );
	newt = oldt;
	newt.c_lflag &= ~( ICANON | ECHO );
	tcsetattr ( STDIN_FILENO, TCSANOW, &newt );

    // Disable buffering on stdin. This ensures that the presence of extra
    // characters is properly detected by select.
    setbuf(stdin, NULL);

	ch = getchar();

    // Restore the stdin buffer
    static char buffer[BUFSIZ];
    setbuf(stdin, buffer);

	tcsetattr ( STDIN_FILENO, TCSANOW, &oldt );
	return ch;
}

void getch_non_blocking( int *outch) {
	unsigned char ch;
	int r;
	struct termios oldt, newt;
	int flags = fcntl(0, F_GETFL, 0);

	fcntl(0, F_SETFL, flags | O_NONBLOCK );

	tcgetattr ( STDIN_FILENO, &oldt );
	newt = oldt;
	newt.c_lflag &= ~( ICANON | ECHO );
	tcsetattr ( STDIN_FILENO, TCSANOW, &newt );

	if ( (r = read(0, &ch, sizeof(ch))) < 0) {
		// can't read!
		*outch = 0;
	} else {
		*outch = (int)ch;
	}

	tcsetattr ( STDIN_FILENO, TCSANOW, &oldt );
	fcntl(0, F_SETFL, flags);
}

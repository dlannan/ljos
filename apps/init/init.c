#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define  LUAVM "/sbin/luajit"

int main(int argc, char *argv[])
{
    /* Launch luajit master process - this will manage subprocesses and modules. */
    char *newargv[] = { LUAVM, "/boot.lua", NULL };
    char *newenviron[] = { NULL };

    /* check file exists - this should _never_ happen */
    // FILE *fh = fopen("/sbin/luajit", "rb");
    // if( fh == NULL ) {
    //     perror("Disaster - /sbin/luajit not found.\n");
    //     exit(EXIT_FAILURE);
    // }
    // fclose(fh);

never_leave:
    execve(LUAVM, newargv, newenviron);
    perror("execve");   /* execve() returns only on error */
    goto never_leave;
    /* Should never get here!! */
    return 0;
}

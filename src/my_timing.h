#include <sys/time.h>
#include <sys/wait.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include "mpi.h"

//#define SYSTEM(s) my_system(s)
#define BARRIER(comm) my_barrier(comm, #comm)

inline double get_current_time()
{
    struct timeval tv;
    gettimeofday(&tv, 0);
    return (double)tv.tv_sec + (double)tv.tv_usec * 1.0e-6;
}


inline int SYSTEM(const char *fmt, ...)
#ifdef __GNUC__
__attribute__((format(printf, 1, 2)))
#endif
;

inline int SYSTEM(const char *fmt, ...)
{
    int ret, stat, sig;
    double t;

    va_list ap;
    const size_t buf_size = 1024;
    char command[buf_size];

    va_start(ap, fmt);
    if (vsnprintf(command, buf_size, fmt, ap) >= buf_size) {
        fprintf(stderr, "*** error: too small buf_size\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    fprintf(stderr, "<<<< %s\n", command);
    t = get_current_time();
    ret = system(command);
    t = get_current_time() - t;
    fprintf(stderr, ">>>> time = %f\n\n", t);

    if (WIFEXITED(ret)) {
        stat = WEXITSTATUS(ret);
        if (stat == 0) return stat;  /* normal return */
        fprintf(stderr, "stat = %d\n", stat);
    } else if (WIFSIGNALED(ret)) {
        sig = WTERMSIG(ret);
        fprintf(stderr, "sig = %d (%s)\n", sig, strsignal(sig));
    } else {
        fprintf(stderr, "ret = %d\n", ret);
    }

    fflush(stdout); fflush(stderr);
    MPI_Abort(MPI_COMM_WORLD, ret);

    return ret; /* NOTREACHED */
}


inline int my_barrier(MPI_Comm comm, const char* comm_str)
{
    int ret;
    double t;

    fprintf(stderr, "MPI_Barrier(%s)", comm_str);
    t = get_current_time();
    ret = MPI_Barrier(comm);
    t = get_current_time() - t;
    fprintf(stderr, " >>>> time = %f\n\n", t);

    return ret;
}


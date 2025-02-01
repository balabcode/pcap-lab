#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, fact=1, factsum, temp;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Errhandler_set(MPI_COMM_WORLD, MPI_ERRORS_RETURN);

    temp = rank+1;
    MPI_Sca(&temp, &fact, 1, MPI_CHAR, MPI_PROD, MPI_COMM_WORLD);
    MPI_Reduce(&fact, &factsum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    if (rank == 0) {
        fprintf(stdout, "Sum of all factorials: %d\n", factsum);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}


// student@dbl-35:~/Documents/220962448/lab4$ mpicc -o out/q5 q5_error_demo.c 
// q5_error_demo.c: In function ‘main’:
// q5_error_demo.c:13:5: warning: implicit declaration of function ‘MPI_Sca’; did you mean ‘MPI_Scan’? [-Wimplicit-function-declaration]
//    13 |     MPI_Sca(&temp, &fact, 1, MPI_CHAR, MPI_PROD, MPI_COMM_WORLD);
//       |     ^~~~~~~
//       |     MPI_Scan
// /usr/bin/ld: /tmp/ccVXLSxY.o: in function `main':
// q5_error_demo.c:(.text+0x8a): undefined reference to `MPI_Sca'
// collect2: error: ld returned 1 exit status

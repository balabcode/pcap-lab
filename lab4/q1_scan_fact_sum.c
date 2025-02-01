#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, fact=1, factsum, temp;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    temp = rank+1;
    MPI_Scan(&temp, &fact, 1, MPI_INT, MPI_PROD, MPI_COMM_WORLD);
    MPI_Reduce(&fact, &factsum, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);
    if (rank == 0) {
        fprintf(stdout, "Sum of all factorials: %d\n", factsum);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}

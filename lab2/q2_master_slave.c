#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, x;
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Enter a value: ");
        scanf("%d", &x);

        for(int i = 1; i < size; i++) {
            MPI_Send(&x, 1, MPI_INT, i, i, MPI_COMM_WORLD);
        }
        fprintf(stdout, "Sent from master!\n");
        fflush(stdout);
    }
    else {
        MPI_Recv(&x, 1, MPI_INT, 0, rank, MPI_COMM_WORLD, &status);
        fprintf(stdout, "Received %d in process %d\n", x, rank);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
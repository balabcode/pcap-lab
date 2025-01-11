#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, x;
    MPI_Status status;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank == 0) {
        printf("Enter value: ");
        scanf("%d", &x);

        MPI_Send(&x, 1, MPI_INT, 1, 1, MPI_COMM_WORLD);

        MPI_Recv(&x, 1, MPI_INT, size-1, 1, MPI_COMM_WORLD, &status);
    }
    else {
        MPI_Recv(&x, 1, MPI_INT, rank-1, 1, MPI_COMM_WORLD, &status);
        ++x;
        if (rank < size-1){
            MPI_Send(&x, 1, MPI_INT, rank+1, 1, MPI_COMM_WORLD);
            fprintf(stdout, "Process %d to %d: %d\n", rank, rank+1, x);
            fflush(stdout);
        }
        else {
            MPI_Send(&x, 1, MPI_INT, 0, 1, MPI_COMM_WORLD);
            fprintf(stdout, "Process %d to %d: %d\n", rank, 0, x);
            fflush(stdout);
        }
    }

    MPI_Finalize();
    return 0;
}
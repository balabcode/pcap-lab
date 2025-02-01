#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, arr[3][3], row[3], target, row_count=0, count=0;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        fprintf(stdout, "Enter 9 numbers: ");
        for(int i = 0; i < 3; i++) {
            for(int j = 0; j < 3; j++) {
                scanf("%d", &arr[i][j]);
            }
        }
        fprintf(stdout, "\nEnter a number to be searched: ");
        scanf("%d", &target);
        fprintf(stdout, "\n");
        fflush(stdout);
    }

    MPI_Bcast(&target, 1, MPI_INT, 0, MPI_COMM_WORLD);
    MPI_Scatter(&arr, 3, MPI_INT, &row, 3, MPI_INT, 0, MPI_COMM_WORLD);

    for(int i = 0; i < 3; i++) {
        if (row[i] == target) row_count++;
    }

    MPI_Reduce(&row_count, &count, 1, MPI_INT, MPI_SUM, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        fprintf(stdout, "Number of occurences of %d: %d\n", target, count);
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}
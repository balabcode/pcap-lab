#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, arr[4][4], row[4], rowsum[4] = {0,0,0,0};
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        fprintf(stdout, "Enter 16 numbers: ");
        for(int i = 0; i < 4; i++) {
            for(int j = 0; j < 4; j++) {
                scanf("%d", &arr[i][j]);
            }
        }
        fprintf(stdout, "\n");
        fflush(stdout);
    }

    MPI_Scatter(&arr, 4, MPI_INT, &row, 4, MPI_INT, 0, MPI_COMM_WORLD);

    MPI_Scan(&row, &rowsum, 4, MPI_INT, MPI_SUM, MPI_COMM_WORLD);

    MPI_Gather(&rowsum, 4, MPI_INT, &arr, 4, MPI_INT, 0, MPI_COMM_WORLD);

    if(rank == 0) {
        for(int i = 0; i < 4; i++) {
            for(int j = 0; j < 4; j++) {
                fprintf(stdout, "%d ", arr[i][j]);
            }
            fprintf(stdout, "\n");
        }
    }
    fflush(stdout);
    MPI_Finalize();
    return 0;
}

// Enter 16 numbers: 1 2 3 4 1 2 3 1 1 1 1 1 2 1 2 1

// 1 2 3 4 
// 2 4 6 5 
// 3 5 7 6 
// 5 6 9 7 
#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    int rank, size, m, *arr, *small;
    double avg, *avgs;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        fprintf(stdout, "Enter num: ");
        scanf("%d", &m);
        fflush(stdout);
    }

    MPI_Bcast(&m, 1, MPI_INT, 0, MPI_COMM_WORLD);

    small = (int*) calloc(m, sizeof(int));
    arr = (int*) calloc(m*size, sizeof(int));
    avgs = (double*) calloc(size, sizeof(double));

    if (rank == 0) {
        fprintf(stdout, "Enter %d elements: ", m*size);
        for(int i = 0; i < m*size; i++) scanf("%d", &arr[i]);
        fflush(stdout);
    }

    MPI_Scatter(arr, m, MPI_INT, small, m, MPI_INT, 0, MPI_COMM_WORLD);

    avg = 0;
    for(int i = 0; i < m; i++) avg += small[i];
    avg /= m;

    MPI_Gather(&avg, 1, MPI_DOUBLE, avgs, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    if(rank == 0) {
        fprintf(stdout, "Averages: ");
        for(int i = 0; i < size; i++) fprintf(stdout, "%.1f  ", avgs[i]);
        fprintf(stdout, "\n");
        fflush(stdout);
    }

    free(small);
    free(arr);
    free(avgs);

    MPI_Finalize();
    return 0;
}
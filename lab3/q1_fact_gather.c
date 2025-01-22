#include <mpi.h>
#include <stdio.h>

int factorial(int n) {
    int f = 1;
    for(int i = 1; i <= n; i++) f *= i;
    return f;
}

int main(int argc, char *argv[]) {
    int rank, size, fact, num, facts[10], nums[10] = {1,2,3,4,5,6,7,8,9,10};
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    MPI_Scatter(&nums, 1, MPI_INT, &num, 1, MPI_INT, 0, MPI_COMM_WORLD);
    fact = factorial(num);
    MPI_Gather(&fact, 1, MPI_INT, &facts, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        fprintf(stdout, "Factorials: ");
        for(int i = 0; i < 10; i++) fprintf(stdout, "%d  ", facts[i]);
        fprintf(stdout, "\n");
        fflush(stdout);
    }

    MPI_Finalize();
    return 0;
}
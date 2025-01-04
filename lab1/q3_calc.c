// Write a program in MPI to simulate simple calculator. Perform each operation using different process in parallel.

#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int x = 5, y = 4;

    switch(rank) {
        case 0:
        printf("Addition: %d\n", x+y);
        break;

        case 1:
        printf("Subtraction: %d\n", x-y);
        break;

        case 2:
        printf("Multiplication: %d\n", x*y);
        break;

        case 3:
        printf("Division: %.2f\n", (float)x/y);
        break;

        default:
        printf("Only the basic math operations!\n");
        break;
    }

    MPI_Finalize();
    return 0;
}
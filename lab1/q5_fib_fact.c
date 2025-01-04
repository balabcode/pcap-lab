// Write a program in MPI where even ranked process prints factorial of the rank and odd ranked process prints ranks Fibonacci number.

#include <stdio.h>
#include <mpi.h>

int fact(int n) {
    int f=1;
    for(int i = 1; i <= n; i++) f *= i;
    return f;
}

int fib(int n) {
    if (n == 0) return 0;
    if (n == 1) return 1;
    return fib(n-1) + fib(n-2);
}

int main(int argc, char *argv[]) {
    int rank, size;
    
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank % 2 == 0) {
        printf("Rank: %d, Factorial: %d\n", rank, fact(rank));
    } else {
        printf("Rank: %d, Fibonacci: %d\n", rank, fib(rank));
    }

    MPI_Finalize();
    return 0;
}
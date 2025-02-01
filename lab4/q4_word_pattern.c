#include <stdio.h>
#include <mpi.h>
#include <string.h>
#include <stdlib.h>

int till(int n) {
    return n*(n+1)/2;
}

int main(int argc, char *argv[]) {
    int rank, size, n_res, n_s;
    char *s, *res, c;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Status status;

    if (rank == 0) {
        n_res = till(size) + 1;
        s = (char*) calloc(size + 1, sizeof(char));
        res = (char*) calloc(n_res, sizeof(char));

        fprintf(stdout, "Enter a word of length %d: ", size);
        fgets(s, size + 1, stdin);
        n_s = strlen(s);
        if (s[n_s - 1] == '\n') {
            s[n_s - 1] = '\0';
            n_s--;
        }
    }

    MPI_Scatter(s, 1, MPI_CHAR, &c, 1, MPI_CHAR, 0, MPI_COMM_WORLD);

    for (int i = 0; i <= rank; i++) {
        MPI_Send(&c, 1, MPI_CHAR, 0, rank + i, MPI_COMM_WORLD);
    }

    if (rank == 0) {
        for (int i = 0; i < size; i++) {
            for (int j = 0; j <= i; j++) {
                MPI_Recv(&res[till(i) + j], 1, MPI_CHAR, i, i + j, MPI_COMM_WORLD, &status);
            }
        }
        res[n_res - 1] = '\0';
        fprintf(stdout, "Resulting String: %s\n", res);
    }

    MPI_Finalize();
    return 0;
}

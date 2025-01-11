#include <stdio.h>
#include <string.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size, len;
    char word[100];
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (rank == 0) {
        printf("Word: ");
        scanf("%s", &word);
        len = strlen(word);

        MPI_Ssend(&len, 1, MPI_INT, 1, 1, MPI_COMM_WORLD);
        MPI_Ssend(&word, len, MPI_CHAR, 1, 2, MPI_COMM_WORLD);

        fprintf(stdout, "Sent: %s\n", word);
        fflush(stdout);

        MPI_Recv(&word, len, MPI_CHAR, 1, 3, MPI_COMM_WORLD, &status);
        fprintf(stdout, "Toggled String: %s\n", word);
        fflush(stdout);
    }
    else if (rank == 1) {
        MPI_Recv( &len , 1 , MPI_INT , 0 , 1 , MPI_COMM_WORLD , &status);
        MPI_Recv(&word , len , MPI_CHAR , 0 , 2 , MPI_COMM_WORLD , &status);

        fprintf(stdout, "Received: %s\n", word);
        fflush(stdout);

        for (int i = 0; i < len; i++) {
            word[i] ^= 32;
        }
        MPI_Ssend(&word, len, MPI_CHAR, 0, 3, MPI_COMM_WORLD);
    }

    MPI_Finalize();
    return 0;
}
#include <stdio.h>
#include <mpi.h>
#include <string.h>
#include <stdlib.h>


int main(int argc, char *argv[]) {
    int rank, size, n, nvow, *nvows, tot;
    char *s, *r;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank == 0) {
        s = (char*) calloc(100, sizeof(char));
        fprintf(stdout, "Enter a string: ");
        fgets(s, 100, stdin);
        n = strlen(s);
        s[n-1] = '\0';
        n--;

        if (n % size != 0) {
            fprintf(stdout, "Enter a string with valid number of chars\n");
            fprintf(stdout, "%d", n);
            fflush(stdout);
            exit(0);
        }
        fflush(stdout);
    }

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);

    int csize = n/size;

    r = (char*) calloc(csize, sizeof(char));
    nvows = (int*) calloc(size, sizeof(int));


    MPI_Scatter(s, csize, MPI_CHAR, r, csize, MPI_CHAR, 0, MPI_COMM_WORLD);

    nvow = csize;
    for(int i = 0; i < csize; i++) {
        if(r[i] == 'a' || r[i] == 'e' || r[i] == 'i' || r[i] == 'o' || r[i] == 'u') {
            nvow--;
        }
    }

    MPI_Gather(&nvow, 1, MPI_INT, nvows, 1, MPI_INT, 0, MPI_COMM_WORLD);

    if(rank == 0) {
        fprintf(stdout, "Non Vowel Counts: ");

        tot = 0;
        for(int i = 0; i < size; i++) {
            fprintf(stdout, "%d  ", nvows[i]);
            tot += nvows[i];
        }
        fprintf(stdout, "\n");
        fprintf(stdout, "Total: %d\n", tot);
        fflush(stdout);
    }
    MPI_Finalize();
    return 0;
}
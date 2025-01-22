#include <stdio.h>
#include <mpi.h>
#include <string.h>
#include <stdlib.h>

char* combine(char *s1, char *s2, int n, char* res) {
    for(int i = 0; i < n; i++) {
        res[2*i] = s1[i];
        res[2*i + 1] = s2[i];
    }
}

int main(int argc, char *argv[]) {
    int rank, size, n;
    char *s1, *s2, *r1, *r2, *s_combined, *r_combined;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if(rank == 0) {
        s1 = (char*) calloc(100, sizeof(char));
        fprintf(stdout, "Enter a string: ");
        fgets(s1, 100, stdin);
        n = strlen(s1);
        s1[n-1] = '\0';
        n--;

        s2 = (char*) calloc(100, sizeof(char));
        fprintf(stdout, "Enter another string: ");
        fgets(s2, 100, stdin);
        n = strlen(s2);
        s2[n-1] = '\0';
        n--;
        fflush(stdout);
    }

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
    int csize = n/size;
    r1 = (char*) calloc(csize, sizeof(char));
    r2 = (char*) calloc(csize, sizeof(char));
    r_combined = (char*) calloc(2*csize, sizeof(char));
    s_combined = (char*) calloc(2*n, sizeof(char));

    MPI_Scatter(s1, csize, MPI_CHAR, r1, csize, MPI_CHAR, 0, MPI_COMM_WORLD);
    MPI_Scatter(s2, csize, MPI_CHAR, r2, csize, MPI_CHAR, 0, MPI_COMM_WORLD);

    combine(r1, r2, n, r_combined);

    MPI_Gather(r_combined, 2*csize, MPI_CHAR, s_combined, 2*csize, MPI_CHAR, 0, MPI_COMM_WORLD);
    
    if(rank == 0) {
        fprintf(stdout, "String 1: ");
        fputs(s1, stdout);
        fprintf(stdout, "\n");

        fprintf(stdout, "String 2: ");
        fputs(s2, stdout);
        fprintf(stdout, "\n");

        fprintf(stdout, "Combined: ");
        fputs(s_combined, stdout);
        fprintf(stdout, "\n");
        fflush(stdout);
    }


    MPI_Finalize();
    return 0;
}
#include <stdio.h>
#include <mpi.h>

int main(int argc, char *argv[]) {
    int rank, size;
    MPI_Status status;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int arr[size];

    if (rank == 0) {
        printf("Enter %d elements: ", size);
        for(int i = 0; i < size; i++) {
            scanf("%d", &arr[i]);
        }

        for(int i = 1; i < size; i++) {
            MPI_Send(&arr[i], 1, MPI_INT, i, i, MPI_COMM_WORLD);
        }
        fprintf(stdout, "Sent!\n");
        fflush(stdout);

        for(int i = 1; i < size; i++) {
            MPI_Recv(&arr[i], 1, MPI_INT, i, i, MPI_COMM_WORLD, &status);
        }
        fprintf(stdout, "Toggled Array: ");
        for(int i = 0; i < size; i++) fprintf(stdout, "%d  ", arr[i]);
        printf("\n");
        fflush(stdout);
    }

    else {
        int temp;
        MPI_Recv(&temp, 1, MPI_INT, 0, rank, MPI_COMM_WORLD, &status);

        if (rank % 2 == 0) {
            temp = temp * temp;
            MPI_Send(&temp, 1, MPI_INT, 0, rank, MPI_COMM_WORLD);
            fprintf(stdout, "Output of Process %d: %d\n", rank, temp);
            fflush(stdout);
        }
        else {
            temp = temp * temp * temp;
            MPI_Send(&temp, 1, MPI_INT, 0, rank, MPI_COMM_WORLD);
            fprintf(stdout, "Output of Process %d: %d\n", rank, temp);
            fflush(stdout);
        }
    }
    MPI_Finalize();
    return 0;
}


// #include <stdio.h>
// #include <mpi.h>

// int main(int argc, char *argv[]) {
//     int rank, size;
//     MPI_Status status;

//     MPI_Init(&argc, &argv);
//     MPI_Comm_rank(MPI_COMM_WORLD, &rank);
//     MPI_Comm_size(MPI_COMM_WORLD, &size);

//     int arr[size];

//     if (rank == 0) {
//         printf("Enter %d elements: ", size);
//         for(int i = 0; i < size; i++) {
//             scanf("%d", &arr[i]);
//         }

//         int buffer[(size+1) * sizeof(int) + 96]; 
//         MPI_Buffer_attach(&buffer, (size+1) * sizeof(int) + 96);
//         for(int i = 1; i < size; i++) {
//             MPI_Bsend(&arr[i], 1, MPI_INT, i, i, MPI_COMM_WORLD);
//         }
//         fprintf(stdout, "Sent!\n");
//         fflush(stdout);

//         for(int i = 1; i < size; i++) {
//             MPI_Recv(&arr[i], 1, MPI_INT, i, i, MPI_COMM_WORLD, &status);
//         }
//         fprintf(stdout, "Toggled Array: ");
//         for(int i = 0; i < size; i++) fprintf(stdout, "%d\t", arr[i]);
//     }

//     else {
//         int temp;
//         MPI_Recv(&temp, 1, MPI_INT, 0, rank, MPI_COMM_WORLD, &status);

//         if (rank % 2 == 0) {
//             temp = temp * temp;
//             MPI_Bsend(&temp, 1, MPI_INT, 0, rank, MPI_COMM_WORLD);
//         }
//         else {
//             temp = temp * temp * temp;
//             MPI_Bsend(&temp, 1, MPI_INT, 0, rank, MPI_COMM_WORLD);
//         }
//     }
// }
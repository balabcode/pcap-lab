// Write a program in CUDA to read MXN matrix A and replace 1“ row of this matrix by same
// elements, 2"¢ row elements by square of each element and 3" row elements by cube of each element
// and so on.

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void matrix_format(int *mat, int *out, int r, int c) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if(row < r) {
        int elem;
        for(int i = 0; i < c; i++) {
            elem = (int)pow((float)mat[row*c + i], (float)row+1);
            out[row*c + i] = elem;
        }
    }
}


int main() {
    int r, c;
    printf("Rows: ");
    scanf("%d", &r);
    printf("Columns: ");
    scanf("%d", &c);

    int mat[r][c], out[r][c];

    printf("Enter matrix:\n");
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            scanf("%d", &mat[i][j]);
        }
    }

    int *d_mat, *d_out;
    cudaMalloc((void **)&d_mat, r * c * sizeof(int));
    cudaMalloc((void **)&d_out, r * c * sizeof(int));

    cudaMemcpy(d_mat, mat, r * c * sizeof(int), cudaMemcpyHostToDevice);

    matrix_format<<<dim3(ceil(r/32.0)), dim3(32)>>>(d_mat, d_out, r, c);
    cudaMemcpy(out, d_out, r * c * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Result:\n");
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            printf("%d ", out[i][j]);
        }
        printf("\n");
    }

    cudaFree(d_mat);
    cudaFree(d_out);
    return 0;
}

// student@dbl-35:~/Documents/220962448/lab9$ ./out/q2
// Rows: 3
// Columns: 3
// Enter matrix:
// 1 2 3 1 2 3 1 2 3
// Result:
// 1 2 3 
// 1 4 9 
// 1 8 27
// Write a program in CUDA to perform parallel Sparse Matrix - Vector multiplication using com-
// pressed sparse row (CSR) storage format. Represent the input sparse matrix in CSR format in the
// host code.

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdlib.h>

__global__ void spvm(int *values, int *col_indices, int *row_ptrs, int *x, int *y, int num_rows) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < num_rows) {
        int start = row_ptrs[row];
        int end = row_ptrs[row + 1];
        int sum = 0;
        for (int j = start; j < end; j++) {
            sum += values[j] * x[col_indices[j]];
        }
        y[row] = sum;
    }
}

int main() {
    int r, c;
    printf("Rows: ");
    scanf("%d", &r);
    printf("Columns: ");
    scanf("%d", &c);

    int mat[r][c];

    printf("Enter matrix:\n");
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            scanf("%d", &mat[i][j]);
        }
    }

    int vec[c];
    printf("Enter vector of size %d:\n", c);
    for (int i = 0; i < c; i++) {
        scanf("%d", &vec[i]);
    }

    int non_zero = 0;
    for (int i = 0; i < r; i++) {
        for (int j = 0; j < c; j++) {
            if (mat[i][j] != 0) {
                non_zero++;
            }
        }
    }

    int *h_values = (int *)malloc(non_zero * sizeof(int));
    int *h_col_indices = (int *)malloc(non_zero * sizeof(int));
    int *h_row_ptrs = (int *)malloc((r + 1) * sizeof(int));

    int idx = 0;
    for (int i = 0; i < r; i++) {
        h_row_ptrs[i] = idx;
        for (int j = 0; j < c; j++) {
            if (mat[i][j] != 0) {
                h_values[idx] = mat[i][j];
                h_col_indices[idx] = j;
                idx++;
            }
        }
    }
    h_row_ptrs[r] = non_zero;

    int *d_values, *d_col_indices, *d_row_ptrs, *d_x, *d_y;
    cudaMalloc((void**)&d_values, non_zero * sizeof(int));
    cudaMalloc((void**)&d_col_indices, non_zero * sizeof(int));
    cudaMalloc((void**)&d_row_ptrs, (r + 1) * sizeof(int));
    cudaMalloc((void**)&d_x, c * sizeof(int));
    cudaMalloc((void**)&d_y, r * sizeof(int));

    cudaMemcpy(d_values, h_values, non_zero * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_indices, h_col_indices, non_zero * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_row_ptrs, h_row_ptrs, (r + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, vec, c * sizeof(int), cudaMemcpyHostToDevice);

    spvm<<<dim3(ceil(r/32.0)), dim3(32)>>>(d_values, d_col_indices, d_row_ptrs, d_x, d_y, r);

    int *h_y = (int *)malloc(r * sizeof(int));
    cudaMemcpy(h_y, d_y, r * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Result:\n");
    for (int i = 0; i < r; i++) {
        printf("%d ", h_y[i]);
    }
    printf("\n");

    free(h_values);
    free(h_col_indices);
    free(h_row_ptrs);
    free(h_y);
    cudaFree(d_values);
    cudaFree(d_col_indices);
    cudaFree(d_row_ptrs);
    cudaFree(d_x);
    cudaFree(d_y);

    return 0;
}

// student@dbl-35:~/Documents/220962448/lab9$ ./out/q1
// Rows: 3
// Columns: 3
// Enter matrix:
// 0 0 1 2 0 0 0 3 0
// Enter vector of size 3:
// 2 0 4
// Result:
// 4 4 0 
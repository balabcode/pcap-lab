#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void matadd_row(int *A, int *B, int *C, int h, int w) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < h) {
        for(int col = 0; col < w; col++) {
            int elem = A[row*h + col] + B[row*h + col];
            C[row*h + col] = elem;
        }

    }
}

__global__ void matadd_col(int *A, int *B, int *C, int h, int w) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (col < w) {
        for(int row = 0; row < h; row++) {
            int elem = A[row*h + col] + B[row*h + col];
            C[row*h + col] = elem;
        }

    }
}

__global__ void matadd_elem(int *A, int *B, int *C, int h, int w) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int col = blockIdx.y * blockDim.y + threadIdx.y;

    if (row < h && col < w) {
        int elem = A[row*h + col] + B[row*h + col];
        C[row*h + col] = elem;
    }
}



int main() {
    int A[4][4] = {
        {5, 15, 2, 14},
        {9, 13, 13, 5},
        {12, 2, 11, 9},
        {18, 8, 14, 4}
    };
    int B[4][4] = {
        {2, 8, 1, 6},
        {7, 4, 9, 0},
        {6, 2, 3, 7},
        {9, 5, 8, 3}
    };

    int h = 4, w = 4;
    int *d_A, *d_B, *d_C, C[h][w];

    cudaMalloc((void **)&d_A, h*w*sizeof(int));
    cudaMalloc((void **)&d_B, w*w*sizeof(int));
    cudaMalloc((void **)&d_C, h*w*sizeof(int));

    cudaMemcpy(d_A, A, h*w*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, w*w*sizeof(int), cudaMemcpyHostToDevice);

    // a:
    // dim3 threads_a(32, 1, 1);
    // dim3 blocks_a(ceil(h / 32.0), 1, 1);
    // matadd_row<<<blocks_a, threads_a>>>(d_A, d_B, d_C, h, w);

    // b:
    // dim3 threads_b(32, 1, 1);
    // dim3 blocks_b(ceil(w / 32.0), 1, 1);
    // matadd_col<<<blocks_b, threads_b>>>(d_A, d_B, d_C, h, w);

    // c:
    dim3 threads_c (32, 32, 1);
    dim3 blocks_c (ceil(h/32.0), ceil(w/32.0), 1);
    matadd_elem<<<blocks_c, threads_c>>>(d_A, d_B, d_C, h, w);


    cudaMemcpy(C, d_C, h*w*sizeof(int), cudaMemcpyDeviceToHost);
    printf("Result: ");
    for(int i = 0; i < h; i++) {
        for(int j = 0; j < w; j++) {
            printf("%d  ", C[i][j]);
        }
        printf("\n");
    }
    printf("\n");

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);
    return 0;
}


// Result: 7  23  3  20  
// 16  17  22  5  
// 18  4  14  16  
// 27  13  22  7 
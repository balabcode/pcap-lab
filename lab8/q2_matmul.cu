#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void matmul_row(int *A, int *B, int *C, int hA, int wA, int wB) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < hA) {
        for(int col = 0; col < wB; col++) {
            int elem = 0;
            for(int k = 0; k < wA; k++) {
                elem += A[row*wA + k] * B[k*wB + col];
            }
            C[row*wB + col] = elem;
        }
    }
}

__global__ void matmul_col(int *A, int *B, int *C, int hA, int wA, int wB) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    if (col < wB) {
        for(int row = 0; row < hA; row++) {
            int elem = 0;
            for(int k = 0; k < wA; k++) {
                elem += A[row*wA + k] * B[k*wB + col];
            }
            C[row*wB + col] = elem;
        }
    }
}

__global__ void matmul_elem(int *A, int *B, int *C, int hA, int wA, int wB) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    int col = blockIdx.y * blockDim.y + threadIdx.y;
    if(row < hA && col < wB) {
        int elem = 0;
        for(int k = 0; k < wA; k++) {
            elem += A[row*wA + k] * B[k*wB + col];
        }
        C[row*wB + col] = elem;
    }
}

int main() {
    int A[5][4] = {
        {3, 7, 1, 8},
        {2, 9, 4, 5},
        {6, 0, 8, 2},
        {9, 3, 6, 1},
        {4, 5, 7, 9}
    };
    int B[4][6] = {
        {2, 8, 1, 6, 9, 3},
        {7, 4, 9, 0, 5, 8},
        {6, 2, 3, 7, 1, 4},
        {9, 5, 8, 3, 7, 6}
    };

    int hA = 5, wA = 4, wB = 6;
    int *d_A, *d_B, *d_C, C[hA][wB];

    cudaMalloc((void **)&d_A, hA*wA*sizeof(int));
    cudaMalloc((void **)&d_B, wA*wB*sizeof(int));
    cudaMalloc((void **)&d_C, hA*wB*sizeof(int));

    cudaMemcpy(d_A, A, hA*wA*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, B, wA*wB*sizeof(int), cudaMemcpyHostToDevice);

    // a:
    // dim3 threads_a(32, 1, 1);
    // dim3 blocks_a(ceil(h / 32.0), 1, 1);
    // matmul_row<<<blocks_a, threads_a>>>(d_A, d_B, d_C, hA, wA, wB);

    // b:
    // dim3 threads_b(32, 1, 1);
    // dim3 blocks_b(ceil(w / 32.0), 1, 1);
    // matmul_col<<<blocks_b, threads_b>>>(d_A, d_B, d_C, hA, wA, wB);

    // c:
    dim3 threads_c (32, 32, 1);
    dim3 blocks_c (ceil(hA/32.0), ceil(wB/32.0), 1);
    matmul_elem<<<blocks_c, threads_c>>>(d_A, d_B, d_C, hA, wA, wB);


    cudaMemcpy(C, d_C, hA*wB*sizeof(int), cudaMemcpyDeviceToHost);
    printf("Result: ");
    for(int i = 0; i < hA; i++) {
        for(int j = 0; j < wB; j++) {
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

// Result: 133  94  133  49  119  117  
// 136  85  135  55  102  124  
// 78  74  46  98  76  62  
// 84  101  62  99  109  81  
// 166  111  142  100  131  134 
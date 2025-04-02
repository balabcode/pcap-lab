// Write a program in CUDA to perform matrix multiplication using 2D Grid and 2D Block.

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void matmul_shared(int *A, int *B, int *C, int hA, int wA, int wB) {
    int row = blockIdx.y * blockDim.y + threadIdx.x;
    int col = blockIdx.x * blockDim.x + threadIdx.y;

    if (row < hA && col < wB) {
        int sum = 0;
        __shared__ int sA[16][16];
        __shared__ int sB[16][16];

        for (int k = 0; k < wA; k += blockDim.y) {
            int aRow = row, aCol = k + threadIdx.y;
            int bRow = k + threadIdx.x, bCol = col;

            sA[threadIdx.x][threadIdx.y] = (aRow < hA && aCol < wA) ? A[aRow * wA + aCol] : 0;
            sB[threadIdx.x][threadIdx.y] = (bRow < wA && bCol < wB) ? B[bRow * wB + bCol] : 0;

            __syncthreads();

            for (int j = 0; j < blockDim.y; ++j) {
                sum += sA[threadIdx.x][j] * sB[j][threadIdx.y]; 
            }
            __syncthreads();
        }
        C[row * wB + col] = sum;
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

    dim3 threads_c (16, 16, 1);
    dim3 blocks_c (ceil(wB/16.0), ceil(hA/16.0), 1);
    matmul_shared<<<blocks_c, threads_c>>>(d_A, d_B, d_C, hA, wA, wB);


    cudaMemcpy(C, d_C, hA*wB*sizeof(int), cudaMemcpyDeviceToHost);
    printf("Result: \n");
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

// student@dbl-35:~/Documents/220962448/lab10$ ./out/q1
// Result: 
// 133  94  133  49  119  117  
// 136  85  135  55  102  124  
// 78  74  46  98  76  62  
// 84  101  62  99  109  81  
// 166  111  142  100  131  134  

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <math.h>

__constant__ float d_M_constant[5];

__global__ void convolution_1d(float *N, float *P, int mask_width, int width) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < width) {
        int mask_radius = mask_width / 2;
        int tile_size = blockDim.x + 2 * mask_radius;
        __shared__ float s_N[7];
        
        int block_start = blockIdx.x * blockDim.x - mask_radius;
        
        for (int j = 0; j < (tile_size + blockDim.x - 1) / blockDim.x; j++) {
            int load_index = threadIdx.x + j * blockDim.x;
            if (load_index < tile_size) {
                int global_index = block_start + load_index;
                s_N[load_index] = (global_index >= 0 && global_index < width) ? N[global_index] : 0.0f;
            }
        }
        __syncthreads();

        float Pval = 0.0f;
        for (int j = 0; j < mask_width; j++) {
            Pval += s_N[threadIdx.x + j] * d_M_constant[j];
        }
        P[i] = Pval;
    }
}

int main() {
    int width, mask_width = 5;
    float M[] = {3, 4, 5, 4, 3};

    printf("Enter size of array: ");
    scanf("%d", &width);
    float N[width], P[width];

    printf("Enter elements: ");
    for (int i = 0; i < width; i++) {
        scanf("%f", &N[i]);
    }

    float *d_N, *d_P;
    int size = width * sizeof(float);
    cudaMalloc((void**)&d_N, size);
    cudaMalloc((void**)&d_P, size);

    cudaMemcpy(d_N, N, size, cudaMemcpyHostToDevice);
    cudaMemcpyToSymbol(d_M_constant, M, mask_width * sizeof(float));

    dim3 blk(ceil((float)width / 3.0), 1, 1);
    dim3 thr(3, 1, 1);

    convolution_1d<<<blk, thr>>>(d_N, d_P, mask_width, width);
    cudaMemcpy(P, d_P, size, cudaMemcpyDeviceToHost);

    printf("Output from 1D Convolution:\n");
    for (int i = 0; i < width; i++) {
        printf("%.2f ", P[i]);
    }
    printf("\n");

    cudaFree(d_N);
    cudaFree(d_P);
    return 0;
}

// student@dbl-35:~/Documents/220962448/lab10$ ./out/q2
// Enter size of array: 7
// Enter elements: 1 2 3 4 5 6 7
// Output from 1D Convolution:
// 22.00  38.00  57.00  76.00  95.00  90.00  74.00
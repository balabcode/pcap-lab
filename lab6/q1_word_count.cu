// Write a program in CUDA which performs convolution operation on one-dimensional input
// array N of size width using a mask array M of size mask_width to produce the resultant one-
// dimensional array P of size width.

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void convolution_1d(float *N, float *M, float *P, int mask_width, int width) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < width) {
        float Pval = 0;
        int N_start = i - (mask_width/2);
        for(int j = 0; j < mask_width; j++) {
            if(N_start + j >= 0 && N_start + j < width)
                Pval += N[N_start + j] * M[j];
        }
        P[i] = Pval;
    }
}

int main() {
    int width, mask_width=5;
    float M[] = {3, 4, 5, 4, 3};

    printf("Enter size of array: ");
    scanf("%d", &width);
    float N[width]={0}, P[width]={0};

    printf("Enter elements: ");
    for(int i = 0; i < width; i++) {
        scanf("%f", &N[i]);
    }

    float *d_N, *d_M, *d_P;
    int size = width*sizeof(float);
    cudaMalloc((void**)&d_N, size);
    cudaMalloc((void**)&d_P, size);
    cudaMalloc((void**)&d_M, mask_width*sizeof(float));

    cudaMemcpy(d_N, N, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_P, P, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_M, M, mask_width*sizeof(float), cudaMemcpyHostToDevice);

    dim3 blk(ceil(width/3.0), 1, 1);
    dim3 thr(3, 1, 1);

    convolution_1d<<<blk, thr>>>(d_N, d_M, d_P, mask_width, width);
    cudaMemcpy(P, d_P, size, cudaMemcpyDeviceToHost);

    printf("Output from 1D Convolution:\n");
    for(int i = 0; i < width; i++) {
        printf("%.2f  ", P[i]);
    }
    printf("\n");

    cudaFree(d_N);
    cudaFree(d_M);
    cudaFree(d_P);

    return 0;
}


// student@dbl-35:~/Documents/220962448/lab6$ ./out/q1
// Enter size of array: 7
// Enter elements: 1 2 3 4 5 6 7
// Output from 1D Convolution:
// 22.00  38.00  57.00  76.00  95.00  90.00  74.00
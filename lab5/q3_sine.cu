// Write a program in CUDA to process a 1D array containing angles in radians to generate
// sine of the angles in the output array. Use appropriate function.


#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>
#include <cuda.h>
#include <math.h>
#define N 16

__global__ void sine(float *a, float *b, int n) {
    size_t index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index < n)
        b[index] = sinf(a[index]);
}

int main(void) {
    float a[N], b[N], size=sizeof(float);
    float *d_a, *d_b;

    cudaMalloc((void **) &d_a, N * size);
    cudaMalloc((void **) &d_b, N * size);

    for(int i = 0; i < N; i++) a[i] = i*M_PI/N+53.2;
    cudaMemcpy(d_a, a, N*size, cudaMemcpyHostToDevice);

    dim3 blk(2, 1, 1);
    dim3 thr(8, 1, 1);
    sine<<<blk, thr>>>(d_a, d_b, N);
    cudaMemcpy(b, d_b, N*size, cudaMemcpyDeviceToHost);

    for(int i = 0; i < N; i++) printf("%.2f  ", b[i]);
    printf("\n");

    cudaFree(d_a);
    cudaFree(d_b);
    return 0;
}

// 0.21  0.01  -0.18  -0.37  -0.55  -0.70  -0.83  -0.92  -0.98  -1.00  -0.98  -0.93  -0.84  -0.71  -0.56  -0.39 
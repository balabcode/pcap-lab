#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdio.h>
#include <cuda.h>
#define N 64

// Write a program in CUDA to add two vectors of length N using
// a) block size as N
// b) N threads

__global__ void add(int *a, int *b, int *c, int n)
{
    size_t index = threadIdx.x + blockIdx.x * blockDim.x;
    if (index < n)
        c[index] = a[index] + b[index];
}

int main(void) {
    int a[N], b[N], c[N], size=sizeof(int);
    int *d_a, *d_b, *d_c;

    cudaMalloc((void **) &d_a, N * size);
    cudaMalloc((void **) &d_b, N * size);
    cudaMalloc((void **) &d_c, N * size);

    for(int i = 0; i < N; i++) a[i] = i*2;
    for(int i = 0; i < N; i++) b[i] = i*3 - 1;

    cudaMemcpy(d_a, a, N*size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, N*size, cudaMemcpyHostToDevice);

    dim3 blk(1, 1, 1);
    dim3 thr(N, 1, 1);
    add<<<blk, thr>>>(d_a, d_b, d_c, N);
    cudaMemcpy(c, d_c, N*size, cudaMemcpyDeviceToHost);

    for(int i = 0; i < N; i++) printf("%d  ", c[i]);
    printf("\n");

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
    return 0;
}
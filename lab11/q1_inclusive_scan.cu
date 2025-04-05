#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void inclusive_scan(int *arr, int *out, int n) {
    extern __shared__ int s_data[];
    int tid = threadIdx.x;
    int i = blockIdx.x * blockDim.x + tid;
    
    s_data[tid] = (i < n) ? arr[i] : 0;
    __syncthreads();

    for (int stride = 1; stride < blockDim.x; stride *= 2) {
        int val = (tid >= stride) ? s_data[tid - stride] : 0;
        __syncthreads();
        s_data[tid] += val;
        __syncthreads();
    }

    if (i < n) out[i] = s_data[tid];
}

int main() {
    int n = 8;
    int arr[] = {1, 2, 3, 4, 5, 6, 7, 8};
    int out[8] = {0};
    int *d_arr, *d_out;

    cudaMalloc((void**)&d_arr, n * sizeof(int));
    cudaMalloc((void**)&d_out, n * sizeof(int));

    cudaMemcpy(d_arr, arr, n * sizeof(int), cudaMemcpyHostToDevice);

    dim3 blocks(ceil(n / 16.0), 1, 1);
    dim3 threads(16, 1, 1);
    inclusive_scan<<<blocks, threads, threads.x * sizeof(int)>>>(d_arr, d_out, n);

    cudaMemcpy(out, d_out, n * sizeof(int), cudaMemcpyDeviceToHost);

    printf("Input array: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", arr[i]);
    }
    printf("\n");

    printf("Inclusive scan result: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", out[i]);
    }
    printf("\n");

    cudaFree(d_arr);
    cudaFree(d_out);

    return 0;
}

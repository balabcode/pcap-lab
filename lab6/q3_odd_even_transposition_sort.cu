// Write a program in CUDA to perform odd even transposition sort in parallel

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void odd_sort(int *N, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < n-1 && i % 2 != 0) {
        if(N[i] > N[i+1]) {
            int temp = N[i];
            N[i] = N[i+1];
            N[i+1] = temp;
        }
    }
}
__global__ void even_sort(int *N, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < n-1 && i % 2 == 0) {
        if(N[i] > N[i+1]) {
            int temp = N[i];
            N[i] = N[i+1];
            N[i+1] = temp;
        }
    }
}

int main() {
    int n;

    printf("Enter number of elems: ");
    scanf("%d", &n);

    int N[n]={0}, size=n*sizeof(int);
    printf("Enter elems:\n");
    for(int i = 0; i < n; i++) scanf("%d", &N[i]);

    int *d_N;
    cudaMalloc((void**)&d_N, size);
    cudaMemcpy(d_N, N, size, cudaMemcpyHostToDevice);

    dim3 blk(ceil(n/3.0), 1, 1);
    dim3 thr(3, 1, 1);

    for(int i = 0; i < n/2; i++) {
        odd_sort<<<blk, thr>>>(d_N, n);
        even_sort<<<blk, thr>>>(d_N, n);
    }

    cudaMemcpy(N, d_N, size, cudaMemcpyDeviceToHost);

    printf("Sorted Array:\n");
    for(int i = 0; i < n; i++) printf("%d ", N[i]);
    printf("\n");

    cudaFree(d_N);
    return 0;
}

// student@dbl-35:~/Documents/220962448/lab6$ ./out/q3
// Enter number of elems: 12
// Enter elems:
// 3 5 6 2 7 4 1 0 8 10 9 11
// Sorted Array:
// 0 1 2 3 4 5 6 7 8 9 10 11 
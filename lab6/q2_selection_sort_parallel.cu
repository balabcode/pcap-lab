// Write a program in CUDA to perform selection sort in parallel

#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>


__global__ void selection_sort(int *N, int *P, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < n) {
        int count = 0;
        for(int j = 0; j < n; j++) {
            if(N[j] < N[i]) count++;
        }
        P[i] = count;
    }
}

__global__ void place_elements(int *N, int *P, int *sorted, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    
    if (i < n) {
        sorted[P[i]] = N[i];
    }
}

int main() {
    int n;

    printf("Enter number of elems: ");
    scanf("%d", &n);

    int N[n]={0}, P[n]={0}, size=n*sizeof(int);
    printf("Enter elems:\n");
    for(int i = 0; i < n; i++) scanf("%d", &N[i]);

    int *d_N, *d_P, *d_sorted;
    cudaMalloc((void**)&d_N, size);
    cudaMalloc((void**)&d_P, size);
    cudaMalloc((void**)&d_sorted, size);
    cudaMemcpy(d_N, N, size, cudaMemcpyHostToDevice);
    cudaMemcpy(d_P, P, size, cudaMemcpyHostToDevice);

    dim3 blk(ceil(n/3.0), 1, 1);
    dim3 thr(3, 1, 1);
    selection_sort<<<blk, thr>>>(d_N, d_P, n);
    place_elements<<<blk, thr>>>(d_N, d_P, d_sorted, n);

    cudaMemcpy(P, d_sorted, size, cudaMemcpyDeviceToHost);
    
    printf("Sorted Array:\n");
    for(int i = 0; i < n; i++) {
        printf("%d ", P[i]);
    }
    printf("\n");

    cudaFree(d_N);
    cudaFree(d_P);
    cudaFree(d_sorted);
    return 0;
}

// student@dbl-35:~/Documents/220962448/lab6$ ./out/q2
// Enter number of elems: 12
// Enter elems:
// 5 7 2 3 4 1 8 9 6 11 10 12
// Sorted Array:
// 1 2 3 4 5 6 7 8 9 10 11 12 

// Write a CUDA program that reads a string S and produces the string RS as follows:
// Input string $: PCAP Output string RS: PCAPPCAPCP
// Note: Each work item copies required number of characters from S in RS

#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void string_process(char *s, char *rs, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if(i < n) {
        int offset = (i * (2*n - i + 1)) / 2;
        for(int k = 0; k < n-i; k++) {
            rs[offset + k] = s[k];
        }
    }
}

int main() {
    char s[100], rs[100*101/2];
    printf("Enter a string: ");
    fgets(s, 100, stdin);
    s[strcspn(s, "\n")] = 0;

    int n = strlen(s);
    int total_size = (n * (n + 1)) / 2;
    char *d_s, *d_rs;

    cudaMalloc((void**)&d_s, n * sizeof(char));
    cudaMalloc((void**)&d_rs, total_size * sizeof(char));

    cudaMemcpy(d_s, s, n * sizeof(char), cudaMemcpyHostToDevice);

    string_process<<<1, n>>>(d_s, d_rs, n);

    cudaMemcpy(rs, d_rs, total_size * sizeof(char), cudaMemcpyDeviceToHost);
    
    rs[total_size] = '\0';
    printf("Output string: %s\n", rs);

    cudaFree(d_s);
    cudaFree(d_rs);

    return 0;
}

// student@dbl-35:~/Documents/220962448/lab7$ ./out/q2
// Enter a string: PCAP
// Output string: PCAPPCAPCP

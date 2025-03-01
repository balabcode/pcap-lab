#include <stdio.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>

__global__ void count_words(char *sentence, char *target, int *start_indices, int num_words, int *wordCount, int targetLen, int sentenceLen) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < num_words) {
        int startIdx = start_indices[idx];
        int wordLen = (idx + 1 < num_words) ? (start_indices[idx + 1] - startIdx - 1) : (sentenceLen - startIdx);

        if (wordLen == targetLen) {
            bool match = true;
            for (int i = 0; i < wordLen && match; i++) {
                if (sentence[startIdx + i] != target[i])
                    match = false;
            }
            if (match)
                atomicAdd(wordCount, 1);
        }
    }
}

int main() {
    char sentence[100], target[100];
    printf("Enter a sentence: ");
    fgets(sentence, 100, stdin);
    sentence[strcspn(sentence, "\n")] = 0;

    printf("Enter the target: ");
    fgets(target, 100, stdin);
    target[strcspn(target, "\n")] = 0;

    int n = strlen(sentence);
    int targetLen = strlen(target);
    int wordCount = 0;

    int max_words = 50;
    int start_indices[max_words];
    int num_words = 0;
    
    int prev = 0;
    for (int i = 0; i <= n && num_words < max_words; i++) {
        if (sentence[i] == ' ' || sentence[i] == '\0') {
            if (i > prev) {
                start_indices[num_words] = prev;
                num_words++;
            }
            prev = i + 1;
        }
    }

    char *d_sentence, *d_target;
    int *d_start_indices, *d_wordCount;
    
    cudaMalloc((void**)&d_sentence, 100 * sizeof(char));
    cudaMalloc((void**)&d_target, 100 * sizeof(char));
    cudaMalloc((void**)&d_start_indices, max_words * sizeof(int));
    cudaMalloc((void**)&d_wordCount, sizeof(int));
    
    cudaMemcpy(d_sentence, sentence, 100 * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_target, target, 100 * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_start_indices, start_indices, max_words * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_wordCount, &wordCount, sizeof(int), cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocks = (num_words + threadsPerBlock - 1) / threadsPerBlock;
    
    count_words<<<blocks, threadsPerBlock>>>(d_sentence, d_target, d_start_indices, num_words, d_wordCount, targetLen, n);
    
    cudaDeviceSynchronize();
    cudaMemcpy(&wordCount, d_wordCount, sizeof(int), cudaMemcpyDeviceToHost);
    
    printf("Number of occurrences: %d\n", wordCount);

    cudaFree(d_sentence);
    cudaFree(d_target);
    cudaFree(d_start_indices);
    cudaFree(d_wordCount);
    
    return 0;
}

// student@dbl-35:~/Documents/220962448/lab7$ ./out/q1
// Enter a sentence: this is a test is a is
// Enter the target: is
// Number of occurrences: 3
// // Write a program in CUDA to count the number of times a given word is repeated in a sentence.
// // (Use Atomic function)

// #include <stdio.h>
// #include <cuda_runtime.h>
// #include <device_launch_parameters.h>

// __global__ void count_words(char *sentence, char* target, int startIdx, int wordLen, int *wordCount, int targetLen) {
//     if (wordLen == targetLen) {
//         for(int i = startIdx; i < startIdx+wordLen; i++) {
//             if(sentence[i] != target[i-startIdx]) {
//                 return;
//             }
//         }
//         atomicAdd(wordCount, 1);
//     }
// }

// int main() {
//     char sentence[100], target[100];
//     printf("Enter a sentence: ");
//     fgets(sentence, 100, stdin);
//     sentence[strcspn(sentence, "\n")] = 0;

//     printf("Enter the target: ");
//     fgets(target, 100, stdin);
//     target[strcspn(target, "\n")] = 0;

//     int n = strlen(sentence);
//     int targetLen = strlen(target);
//     int wordCount=0;
//     dim3 blk(ceil(n/3.0), 1, 1);
//     dim3 thr(3, 1, 1);

//     char *d_sentence, *d_target;
//     int *d_wordCount;
    
//     cudaMalloc((void**)&d_sentence, 100 * sizeof(char));
//     cudaMalloc((void**)&d_target, 100 * sizeof(char));
//     cudaMalloc((void**)&d_wordCount, sizeof(int));
    
//     cudaMemcpy(d_sentence, sentence, 100 * sizeof(char), cudaMemcpyHostToDevice);
//     cudaMemcpy(d_target, target, 100 * sizeof(char), cudaMemcpyHostToDevice);
//     cudaMemcpy(d_wordCount, &wordCount, sizeof(int), cudaMemcpyHostToDevice);

//     int prev = 0;
//     for (int i = 0; i <= n; i++) {
//         if(sentence[i] == ' ' || sentence[i] == '\0') {
//             if (i > prev) {
//                 count_words<<<1,1>>>(d_sentence, d_target, prev, i - prev, d_wordCount, targetLen);
//                 cudaDeviceSynchronize();
//             }
//             prev = i + 1;
//         }
//     }
    
//     cudaMemcpy(&wordCount, d_wordCount, sizeof(int), cudaMemcpyDeviceToHost);
    
//     printf("Number of occurences: %d\n", wordCount);

//     cudaFree(d_sentence);
//     cudaFree(d_target);
//     cudaFree(d_wordCount);
// }

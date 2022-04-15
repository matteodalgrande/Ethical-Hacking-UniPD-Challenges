//https://stackoverflow.com/questions/1289026/syntax-for-a-single-line-while-loop-in-bash
#include <emmintrin.h>
#include <x86intrin.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

//  Windows
#ifdef _WIN32
#include <intrin.h>
uint64_t rdtsc(){
    return __rdtsc();
}
//  Linux/GCC
#else
uint64_t rdtsc(){
    unsigned int lo,hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}
#endif



#define CACHE_WORD_SIZE 2048


uint8_t array[10*CACHE_WORD_SIZE];

int main(void) {
  int junk=0;
  register uint64_t time1, time2;
  volatile uint8_t *addr;
  int i;
  // Initialize the array
  for(i=0; i<10; i++) array[i*CACHE_WORD_SIZE]=1;

  // FLUSH the array from the CPU cache
  for(i=0; i<10; i++) _mm_clflush(&array[i*CACHE_WORD_SIZE]);

  // Access some of the array items
  array[3*CACHE_WORD_SIZE] = 100;
  array[7*CACHE_WORD_SIZE] = 200;
   printf("access to location 3 and 7 array");


  for(i=0; i<10; i++) {
    addr = &array[i*CACHE_WORD_SIZE];
    time1 = rdtsc(&junk);   junk = *addr;
    time2 = rdtsc(&junk) - time1;
    printf("Access time for array[%d*CACHE_WORD_SIZE]: %d CPU cycles\n",i, (int)time2);
  }
  return 0;
}

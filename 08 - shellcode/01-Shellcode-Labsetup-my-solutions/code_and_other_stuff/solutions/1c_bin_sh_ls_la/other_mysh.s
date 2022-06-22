section .text
  global _start 
    _start:
      ;BITS 32
      jmp short todo

    shellcode:
      xor eax, eax            ;Zero out eax
      xor ebx, ebx            ;Zero out ebx
      xor ecx, ecx            ;Zero out ecx
      cdq	      		          ;Zero out edx using the sign bit from eax

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ; push strings --> Store the argument string on stack --> ebx --> string of the command
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ; esi	--> Scratch register.  Also used to pass function argument #2 in 64-bit Linux
      pop esi                 ;Esi contain the string in db
      xor eax, eax

;      7 10 13 17 --> for space
; 18 --> 22 --> 26 --> 30

    ; setup the spaces
      mov[esi+7], al    ; //bin/sh
      mov[esi+10], al   ; -c
      mov[esi+13], al   ; ls -al   
      mov[esi+17], al   ; ls -al

      
      mov[esi+18], esi ; store address of //bin/sh in AAAA

      lea ebx, [esi+8] ; load address of -c
      mov[esi+22], ebx ; store address of -c in BBBB taken from ebx

      lea ebx, [esi+11] ; load address of 'ls -al'
      mov[esi+26], ebx       ; store address of 'ls -al' in CCCC taken from ebx

      mov[esi+30], eax  ;Zero out DDDD load address of NULL

        
      mov ebx, esi            ; Store address of /bin/sh
      lea ecx, [esi+18]       ;Load address of ptr to argv[] array
   
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ; For environment variable --> 
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;xor  edx, edx     ; No env variables 
      lea edx, [esi+31]

      ; Invoke execve()
      xor  eax, eax     ; eax = 0x00000000
      mov   al, 0x0b    ; eax = 0x0000000b       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; %eax : must contain 11, which is the system call number for execve () 
      int 0x80

    todo:
      call shellcode
      db "/bin/sh#-c#ls#-al#AAAABBBBCCCCDDDD"
 
;      7 10 13 17 --> for space
; 18 --> 22 --> 26 --> 30

;   >>> a = "/bin/sh#-c#ls#-al#AAAABBBBCCCCDDDD" 
;   >>> for i,e in enumerate(a):
;   ...   print(';',i,e)
;   ... 
; 0 /
; 1 b
; 2 i
; 3 n
; 4 /
; 5 s
; 6 h
; 7 #
; 8 -
; 9 c
; 10 #
; 11 l
; 12 s
; 13 #
; 14 -
; 15 a
; 16 l
; 17 #
; 18 A
; 19 A
; 20 A
; 21 A
; 22 B
; 23 B
; 24 B
; 25 B
; 26 C
; 27 C
; 28 C
; 29 C
; 30 D
; 31 D
; 32 D
; 33 D
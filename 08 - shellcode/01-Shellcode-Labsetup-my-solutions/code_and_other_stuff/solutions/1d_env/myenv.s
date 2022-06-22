; nasm -f elf32 myenv.s -o myenv.o && ld --omagic -m elf_i386 myenv.o -o myenv && myenv

section .text
global _start
_start:
    BITS 32
    jmp short two
one:
    xor eax, eax            ;Zero out eax
    xor ebx, ebx            ;Zero out ebx
    xor ecx, ecx            ;Zero out ecx
    cdq	      		          ;Zero out edx using the sign bit from eax

    pop esi                 ;Esi contain the string in db
    xor eax, eax

   ; setup the spaces
    mov[esi+12], al     ; space after /usr/bin/env
    mov[esi+21], al     ; space after aaa=1234
    mov[esi+30], al     ; space after bbb=5678
    mov[esi+40], al     ; space after cccc=1234
    mov[esi+45], eax    ; save the argv[1] = NULL ; Zero out DDDD load address of NULL
    mov[esi+61], eax    ; --> set FFFF as NULL --> envp[3] = NULL)

    ; save the argv[0]  
    mov[esi+41], esi ; store address of /usr/bin/env in AAAA

    mov ebx, esi            ; Store address of /etc/bin/env --> ebx --> address of the command
    lea ecx, [esi+41]       ; Load address of ptr to argv[] array --> ecx --> address of the argv[] array


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; For environment variable --> 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lea edx, [esi+13]       ; load aaa 
    mov[esi+49], edx        ; store address of aaa in CCCC taken from edx

    lea edx, [esi+22]       ; load bbb 
    mov[esi+53], edx        ; store address of bbb in DDDD taken from edx

    lea edx, [esi+31]       ; load cccc 
    mov[esi+57], edx        ; store address of cccc in EEEE taken from edx

    ;xor  edx, edx     ; No env variables
    lea edx, [esi+49]

    ; Invoke execve()
    xor  eax, eax     ; eax = 0x00000000
    mov   al, 0x0b    ; eax = 0x0000000b       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; %eax : must contain 11, which is the system call number for execve () 
    int 0x80

two:
    call one
    db '/usr/bin/env#aaa=1234#bbb=5678#cccc=1234#AAAABBBBCCCCDDDDEEEEFFFF' ; Here the string used is /usr/bin/env

    
    
;>>> a = '/usr/bin/env#aaa=1234#bbb=5678#cccc=1234#AAAABBBBCCCCDDDDEEEEFFFF'
;>>> for i,e in enumerate(a):
;...   print(';',i,e)
;... 
; 0 /
; 1 u
; 2 s
; 3 r
; 4 /
; 5 b
; 6 i
; 7 n
; 8 /
; 9 e
; 10 n
; 11 v
; 12 #
; 13 a
; 14 a
; 15 a
; 16 =
; 17 1
; 18 2
; 19 3
; 20 4
; 21 #
; 22 b
; 23 b
; 24 b
; 25 =
; 26 5
; 27 6
; 28 7
; 29 8
; 30 #
; 31 c
; 32 c
; 33 c
; 34 c
; 35 =
; 36 1
; 37 2
; 38 3
; 39 4
; 40 #
; 41 A
; 42 A
; 43 A
; 44 A
; 45 B
; 46 B
; 47 B
; 48 B
; 49 C
; 50 C
; 51 C
; 52 C
; 53 D
; 54 D
; 55 D
; 56 D
; 57 E
; 58 E
; 59 E
; 60 E
; 61 F
; 62 F
; 63 F
; 64 F

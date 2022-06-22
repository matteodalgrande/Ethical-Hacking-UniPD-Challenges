; nasm -f elf32 call.s -o call.o && ld --omagic -m elf_i386 call.o -o call && call

; When we get into the function, i.e.,
;after jumping to location one, the top of the stack is where the return address is stored. Therefore, the pop
;ebx instruction in Line [1] actually get the address of the string on Line [2], and save it to the ebx register.
;That is how the address of the string is obtained.

;if we want to get an executable, we need to use the --omagic option when running the linker program
;(ld), so the code segment is writable. By default, the code segment is not writable. When this program
;runs, it needs to modify the data stored in the code region; if the code segment is not writable, the program
;will crash. This is not a problem for actual attacks, because in attacks, the code is typically injected into a
;writable data segment (e.g. stack or heap). Usually we do not run shellcode as a standalone program.


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
    mov[esi+17], al     ; space after a=11
    mov[esi+22], al     ; space after b=22
    mov[esi+27], eax    ; save the argv[1] = NULL ; Zero out BBBB load address of NULL
    mov[esi+39], eax    ; --> set EEEE as NULL --> envp[3] = NULL)
    

    ; save the argv[0]  
    mov[esi+23], esi ; store address of /usr/bin/env in AAAA

    mov ebx, esi            ; Store address of /etc/bin/env --> ebx --> address of the command
    lea ecx, [esi+23]       ; Load address of ptr to argv[] array --> ecx --> address of the argv[] array

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; For environment variable --> 
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lea edx, [esi+13]       ; load a
    mov[esi+31], edx        ; store address of aaa in CCCC taken from edx

    lea edx, [esi+18]       ; load b
    mov[esi+35], edx        ; store address of bbb in DDDD taken from edx

    lea edx, [esi+31] ; --> load the pointer to the arge[] to the edx

    ; Invoke execve()
    xor  eax, eax     ; eax = 0x00000000
    mov   al, 0x0b    ; eax = 0x0000000b       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; %eax : must contain 11, which is the system call number for execve () 
    int 0x80

two:
    call one
    db "/usr/bin/env*a=11*b=22*AAAABBBBCCCCDDDDEEEE" 	; [2]

; 12, 17, 22 BBBB, EEEE--> zeroers

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
; 12 *
; 13 a
; 14 =
; 15 1
; 16 1
; 17 *
; 18 b
; 19 =
; 20 2
; 21 2
; 22 *
; 23 A
; 24 A
; 25 A
; 26 A
; 27 B
; 28 B
; 29 B
; 30 B
; 31 C
; 32 C
; 33 C
; 34 C
; 35 D
; 36 D
; 37 D
; 38 D
; 39 E
; 40 E
; 41 E
; 42 E



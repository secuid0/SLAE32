#!/bin/bash
echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o $1.o $1.nasm

echo '[+] Linking ...'
ld -melf_i386 -o $1 $1.o

echo '[+] Dumping shellcode ...'

echo '' > shellcode.nasm
for i in `objdump -d $1 | tr '\t' ' ' | tr ' ' '\n' | egrep '^[0-9a-f]{2}$' ` ; do echo -n "\x$i" >> shellcode.nasm; done

echo '[+] Creating new shellcode.c ...'
cat > shellcode.c <<EOF
#include<stdio.h>
#include<string.h>
unsigned char code[] ="\\
EOF
echo -n "\\" >> shellcode.c
cat shellcode.nasm >> shellcode.c

cat >> shellcode.c <<EOF
";
main()
{
        printf("Shellcode Length:  %d\n", strlen(code));
        int (*ret)() = (int(*)())code;
        ret();
}
EOF

echo '[+] Compiling shellcode.c ...'
gcc -fno-stack-protector -z execstack -m32 -o shellcode shellcode.c

echo '[+] Done! Run ./shellcode to execute!'

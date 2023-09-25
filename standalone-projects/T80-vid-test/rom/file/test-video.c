#include <stdio.h>

int main() {
	char *p;
	
	// DRAW A C IN TOP LEFT CORNER
	p = (char*)0x4000;
	*p = 0b00111101;
	p = (char*)0x4100;
	*p = 0b01000011;
	p = (char*)0x4200;
	*p = 0b10000001;
	p = (char*)0x4300;
	*p = 0b10000000;
	p = (char*)0x4400;
	*p = 0b10000000;
	p = (char*)0x4500;
	*p = 0b10000001;
	p = (char*)0x4600;
	*p = 0b01000011;
	p = (char*)0x4700;
	*p = 0b00111101;
	
	p = (char*)0x5800;
	*p = 0b10101011;
	return 0;
}
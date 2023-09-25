#include <stdio.h>
#include ".\terasic_lib\terasic_includes.h"
#include ".\spectrum_comm\DMA\dma_hal.h"

// defines based on https://skoolkid.github.io/rom/buffers/sysvars.html
#define VARS 0x5C4B // Address of variables

#define E_LINE 0x5C59 	// Address of command being typed in
#define K_CUR 0x5C5B 	// Address of cursor
#define CH_ADD 0x5C5D 	// Address of the next character to be interpreted

#define WORKSP 0x5C61 	// Address of temporary work space
#define STKBOT 0x5C63 	// Address of bottom of calculator stack
#define STKEND 0x5C65 	// Address of start of spare space


void DMA_print_err(int ret) {
	switch (ret) {
		case TIMEOUT:
			printf("DMA request timeout");
			break;
		case ALREADY_DONE:
			printf("DMA request already done");
			break;
		default: printf("Unknown err");
	}
}

void generalTest() {
	//---------- Memory -----------//

	// Writes a T to the top left attribute block
	alt_u16 addr = 0x4000;
	alt_u8 data = 0b00000000;
	write_mem(addr, data);
	addr = 0x4100;
	data = 0b11111110;
	write_mem(addr, data);
	addr = 0x4200;
	data = 0b00010000;
	write_mem(addr, data);
	addr = 0x4300;
	data = 0b00010000;
	write_mem(addr, data);
	addr = 0x4400;
	data = 0b00010000;
	write_mem(addr, data);
	addr = 0x4500;
	data = 0b00010000;
	write_mem(addr, data);
	addr = 0x4600;
	data = 0b00010000;
	write_mem(addr, data);
	addr = 0x4700;
	data = 0b00000000;
	write_mem(addr, data);

	// Make colors of top left attribute block RED and BLUE flashing COMMENTED
	addr = 0x5800;
	//data = 0b10010101;
	//write_mem(addr, data);

	// Makes top left 5 attribute blocks be red and blue, with the middle one flashing
	alt_u8 data_buf[5] = {0b00010101, 0b00010101, 0b10010101, 0b00010101, 0b00010101};

	write_buf_mem(addr, data_buf, 0, sizeof(data_buf));

	// Makes main viewport red paper and blue ink PERMANENTLY
	addr = 0x5C8d;
	write_mem(addr, 0b00010001);
	addr = 0x5C8f;
	write_mem(addr, 0b00010001);

	addr = 0x5801;
	data = read_mem(addr);
	printf("read mem: 0x%x\r\n", data);

	//---------- IO -----------//

	// Makes border green (temporarily)
	addr = 0xFEFE;
	data = 0b00000100;
	write_io(addr, data);

	// makes border green permanently (RAM)
	addr = 0x5C48;
	write_mem(addr, 0b00100000);

	// Reads keyboard (SHIFT, Z, X, C, V) (0, 1, 2, 3, 4)
	data = read_io(addr);
	printf("read io: %d\r\n", data);
}

int main() {
	int ret;

	DMA_init();

	ret = DMA_request(10);

	if (ret != 0) {
		DMA_print_err(ret);
	}

	//generalTest();

	/*alt_u16 addr = 0x9D34;
	alt_u8 data_buf[57] = {
		0xFD, 0xCB, 0x02, 0xEE, 0xE5, 0xD5, 0xF3, 0x21, 0x00, 0x40, 0x36, 0xE7,
		0x21, 0x00, 0x41, 0x36, 0x42, 0x21, 0x00, 0x42, 0x36, 0x24, 0x21, 0x00,
		0x43, 0x36, 0x18, 0x21, 0x00, 0x44, 0x36, 0x24, 0x21, 0x00, 0x45, 0x36,
		0x24, 0x21, 0x00, 0x46, 0x36, 0x42, 0x21, 0x00, 0x47, 0x36, 0xE7, 0x21,
		0x00, 0x58, 0x36, 0xAB, 0xD1, 0xE1, 0xC3, 0xA0, 0x12
	};


	write_buf_mem(addr, data_buf, 0, sizeof(data_buf));*/

	// COMENTED: tried to load BASIC program, failed
	/*alt_u16 addr = E_LINE;
	alt_u8 data_buf[6] = {0xD7, 0x5C, 0xD7, 0x5C, 0xD8, 0x5C};
	write_buf_mem(addr, data_buf, 0, sizeof(data_buf));

	addr = WORKSP;
	data_buf[0] = 0xD9;
	data_buf[2] = 0xD9;
	data_buf[4] = 0xD9;
	write_buf_mem(addr, data_buf, 0, sizeof(data_buf));

	addr = 0x5CCB;
	//alt_u8 data_buf[12] = {0x00, 0x01, 0x07, 0x00, 0xF5, 0x22, 0x62, 0x6F, 0x62, 0x22, 0x0D, 0x80}; // 0x80 instead of 0x6E
	alt_u8 data_buf2[13] = {0x00, 0x01, 0x07, 0x00, 0xF5, 0x22, 0x62, 0x6F, 0x62, 0x22, 0x0D, 0x80, 0x0D, 0x80, 0x22,0x62, 0x6f, 0x62, 0x22, 0x0d, 0x80, 0x22};

	printf("size: %d\r\n", sizeof(data_buf));
	write_buf_mem(addr, data_buf2, 0, sizeof(data_buf2));*/

	alt_u16 addr = 0xFF56;
	alt_u8 data_buf[35] = {
		0xF5, 0xD5, 0x11, 0xC0, 0x09, 0x3E, 0x00, 0xCD, 0x0A, 0x0C, 0xD1, 0xF1,
		0xED, 0x45
	};



	write_buf_mem(addr, data_buf, 0, sizeof(data_buf));

	DMA_stop_w_interrupt();

	/*ret = DMA_stop(10);
	printf("%d", ret);*/

	return 0;

}

#include "dma_hal.h"
#include "dma_hw.h"

int DMA_state;
alt_u8 ctrl_bus_state;

void DMA_init() {
	DATA_IN;

	DMA_state = 0;
	ctrl_bus_state = 0b00001111;
	CTRL_BUS_SET(ctrl_bus_state);
	BUS_REQ_CLR;
}

/**
 * Requests DMA from the Z80, attempting "tries" number of times
 */
int DMA_request(int tries) {
	int i;

	if (DMA_state == 1 && BUS_ACK_GET == 1)
		return ALREADY_DONE;


	BUS_REQ_SET;

	i=0;
	do {
		if (i >= tries) {
			BUS_REQ_CLR;
			return TIMEOUT;
		}
		i++;
	} while (BUS_ACK_GET != 1);

	DMA_state = 1;
	return 0;
}

alt_u8 read_mem(alt_u16 addr) {
	alt_u8 data;

	DATA_IN;

	ctrl_bus_state &= READ_SET;
	ctrl_bus_state &= MEM_REQ_SET;
	CTRL_BUS_SET(ctrl_bus_state);

	ADDR_SET(addr);
	usleep(100);
	data = DATA_GET;
	IOWR_ALTERA_AVALON_PIO_DATA(LEDG_PIO_BASE, data);

	ctrl_bus_state |= MEM_REQ_CLR;
	ctrl_bus_state |= READ_CLR;
	CTRL_BUS_SET(ctrl_bus_state);

	return data;
}

void read_buf_mem(alt_u16 addr, int len, alt_u8* ret) {
	for(int i = 0; i < len; i++) {
		ret[i] = read_mem(addr++);
	}
}

void write_mem(alt_u16 addr, const alt_u8 data) {
	//if (addr >= 0x4000 && addr < 0x4100) {
	if (addr == 0x5800) {
		printf("0x%02x (%c), ", data, data);
	}
	DATA_OUT;

	ctrl_bus_state &= WRITE_SET;
	ctrl_bus_state &= MEM_REQ_SET;
	CTRL_BUS_SET(ctrl_bus_state);


	ADDR_SET(addr);
	DATA_SET(data);
	IOWR_ALTERA_AVALON_PIO_DATA(LEDG_PIO_BASE, data);
	usleep(100);

	ctrl_bus_state |= MEM_REQ_CLR;
	ctrl_bus_state |= WRITE_CLR;
	CTRL_BUS_SET(ctrl_bus_state);

	DATA_IN;
}

void write_buf_mem(alt_u16 addr, const alt_u8* data, int start, int len) {
	for (int i = start; i < start+len; i++) {
		write_mem(addr++, data[i]);
	}
}

alt_u8 read_io(alt_u16 addr) {
	alt_u8 data;

	DATA_IN;

	ctrl_bus_state &= READ_SET;
	ctrl_bus_state &= IO_REQ_SET;
	CTRL_BUS_SET(ctrl_bus_state);

	ADDR_SET(addr);
	usleep(100);
	data = DATA_GET;
	IOWR_ALTERA_AVALON_PIO_DATA(LEDG_PIO_BASE, data);

	ctrl_bus_state |= IO_REQ_CLR;
	ctrl_bus_state |= READ_CLR;
	CTRL_BUS_SET(ctrl_bus_state);

	return data;
}
void write_io(alt_u16 addr, alt_u8 data) {
	DATA_OUT;

	ctrl_bus_state &= WRITE_SET;
	ctrl_bus_state &= IO_REQ_SET;
	CTRL_BUS_SET(ctrl_bus_state);


	ADDR_SET(addr);
	DATA_SET(data);
	IOWR_ALTERA_AVALON_PIO_DATA(LEDG_PIO_BASE, data);
	usleep(100);

	ctrl_bus_state |= IO_REQ_CLR;
	ctrl_bus_state |= WRITE_CLR;
	CTRL_BUS_SET(ctrl_bus_state);

	DATA_IN;
}

/**
 * Loops until PC value is observed in the address bus or number of tries exceeded
 */
int wait_for_pc(alt_u16 pc, int tries) {
	alt_u16 addr;
	alt_u16 pc_big = ((pc & 0xFF) << 8) | (pc >> 8);//(pc >> 8); //||
	addr = CPU_ADDR_GET;

	while(1) {
		if (tries-- < 0) return TIMEOUT;
		if (addr == pc_big) break;
		addr = CPU_ADDR_GET;
	}
	return 0;
}

int wait_until_routine_ends(int tries) {
	alt_u16 end_of_screen = END_OF_SCREEN;
	alt_u16 addr;

	while(1) {
		if (tries-- < 0) return TIMEOUT;
		// TODO make sure endianness is good for this comparison
		if (addr > end_of_screen) break;
		addr = CPU_ADDR_GET;
	}
	return 0;
}

/**
 * Stop DMA, attempting "tries" number of times
 * TODO: Is having multiple tries necessary? just in case?
 */
int DMA_stop(int tries) {
	int i;

	if (DMA_state == 0 && BUS_ACK_GET == 0)
		return ALREADY_DONE;


	BUS_REQ_CLR;

	i=0;
	do {
		if (i >= tries) {
			BUS_REQ_SET;
			return TIMEOUT;
		}
		i++;
	} while (BUS_ACK_GET != 0);

	DMA_state = 0;
	return 0;
}

void DMA_stop_w_interrupt() {
	NMI_SET;
	BUS_REQ_CLR;
	usleep(1); // NMI must be on for 80 ns minimum

	if (BUS_ACK_GET != 0) {
		while (BUS_ACK_GET != 0);
		usleep(1);
	}

	NMI_CLR;
	DMA_state = 0;
}

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

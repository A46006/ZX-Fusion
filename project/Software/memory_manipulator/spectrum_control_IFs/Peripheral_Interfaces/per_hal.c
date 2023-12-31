#include "../../spectrum_control_IFs/Peripheral_Interfaces/per_hal.h"

//extern clock_t t0;

void listen_for_en() {
	int read, write, en;
	do {
		//printf("%ul ms\r\n", clock() - t0);
		//usleep(1000000);
		en = EN_GET;
	} while (!en);

	int tries = 500;
	do {
		read = CPU_RD_GET;
		write = CPU_WR_GET;
		//printf("read %d\r\n", read);
		//printf("write %d\r\n", write);
		printf("%d\r\n", tries);
	} while (read == write && tries-- > 0);
}

enum per_if_type get_if_type() {
	/*int read = CPU_RD_GET;
	int write = CPU_WR_GET;
	printf("RD: %d\r\n", read);
	printf("WR: %d\r\n", write);
	if (read == write) {
		return NA;
	}*/
	alt_u8 addr = CPU_ADDR_GET & 0xFF;

	switch (addr) {
		case 0x17:
			return INIT;
		case 0x19:
			return STATE;
		case 0x1B:
			return SD;
		case 0x1D:
			return ONLINE;
	}
	return NA;

}
int get_page_num() {
	if (CPU_RD_GET == CPU_WR_GET) {
		return -1;
	}

	return (CPU_ADDR_GET >> 8) & 0xFF;
}

int get_game_num() {
	if (CPU_WR_GET == 0) {
		return -1;
	}

	return CPU_CMD_GET & 0xF;
}

bool is_read() {
	return CPU_RD_GET;
}
bool is_write() {
	return CPU_WR_GET;
}

void per_cmd_ack() {
	CMD_ACK_SET(1);
	usleep(1000);
	CMD_ACK_SET(0);
}

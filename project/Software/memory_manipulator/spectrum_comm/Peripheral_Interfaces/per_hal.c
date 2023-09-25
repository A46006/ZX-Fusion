#include "../Peripheral_Interfaces/per_hal.h"

void listen_for_en() {
	int read, write, en;
	while(1) {
		en = EN_GET;
		if (!en) {
			continue;
		}
		read = CPU_RD_GET;
		write = CPU_WR_GET;
		if (read != write) {
			printf("RD != WR\r\n");
			break;
		}
	}
}

enum per_if_type get_if_type() {
	int read = CPU_RD_GET;
	int write = CPU_WR_GET;
	printf("RD: %d\r\n", read);
	printf("WR: %d\r\n", write);
	if (read == write) {
		return NA;
	}
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
	return CPU_RD_GET == 1;
}
bool is_write() {
	return CPU_WR_GET == 1;
}

void per_cmd_ack() {
	CMD_ACK_SET(1);
	usleep(1000);
	CMD_ACK_SET(0);
}

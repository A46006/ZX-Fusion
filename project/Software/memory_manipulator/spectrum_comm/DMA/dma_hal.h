#include "..\..\terasic_lib\terasic_includes.h"

#define TIMEOUT -1
#define ALREADY_DONE -2

#define END_OF_SCREEN 0x5800

void DMA_init();

int DMA_request(int tries);

alt_u8 read_mem(alt_u16 addr);
void read_buf_mem(alt_u16 addr, int start, int len, alt_u8* ret);

void write_mem(alt_u16 addr, const alt_u8 data);
void write_buf_mem(alt_u16 addr, const alt_u8* data, int start, int len);

alt_u8 read_io(alt_u16 addr);
void write_io(alt_u16 addr, alt_u8 data);

int wait_for_pc(alt_u16 pc, int tries);
int wait_until_routine_ends(int tries);

int DMA_stop(int tries);
void DMA_stop_w_interrupt();

void DMA_print_err(int ret);

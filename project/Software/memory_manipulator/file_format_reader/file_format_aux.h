#include "../terasic_lib/terasic_includes.h"

#define NMI_ROUTINE_ADDR 0x4000//0xFF50
#define ADDED_STACK_START_ADDR 0x57FC
#define ADDED_STACK_SIZE 4
//#define SP_LOCATION 0x5CC0 // Because it is close to the end of "Reserved for BASIC" area

enum file_type {Z80, SNA};

typedef struct {
	alt_u8 R;
	alt_u8 I;

	alt_u8 Al;
	alt_u8 Fl;
	alt_u8 Hl;
	alt_u8 Ll;
	alt_u8 Dl;
	alt_u8 El;
	alt_u8 Bl;
	alt_u8 Cl;

	alt_u8 A;
	alt_u8 F;
	alt_u8 H;
	alt_u8 L;
	alt_u8 D;
	alt_u8 E;
	alt_u8 B;
	alt_u8 C;

	alt_u16 IY;
	alt_u16 IX;

	alt_u16 SP;
	alt_u16 PC;

	// not actual regs
	alt_u8 IM; // interrupt mode
	alt_u8 IFF1; // enable interrupt (0 = DI)
	alt_u8 IFF2; // flip flop
	alt_u8 border; // border color
} REGS;


typedef struct {
	alt_u16 SP;
	size_t size;
	alt_u8* data;
} STACK_ADD;

alt_u16 conv_data_8_16(alt_u8* data, int offset);
alt_u16 reverse_16(alt_u16 data);

int get_routine_size_SNA();
int get_routine_size_z80();

STACK_ADD generate_full_stack_addition(REGS regs, const enum file_type type);

STACK_ADD generate_AF_stack_addition(REGS regs, const enum file_type type, bool add_pc);

alt_u8* generate_routine(REGS regs, const enum file_type type, int routine_size);

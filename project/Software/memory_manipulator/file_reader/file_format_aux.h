#include "../terasic_lib/terasic_includes.h"

#define NMI_ROUTINE_ADDR 0x4000 // the address where the NMI routine is injected
#define OLD_STACK_START_ADDR 0x57FC // top of the old stack, where old PC is stored
#define OLD_STACK_SIZE 4 // size of that old stack
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
	alt_u8 data[10];
} STACK_ADD;

alt_u16 conv_data_8_16(alt_u8* data, int offset);
alt_u16 reverse_16(alt_u16 data);

int get_LOAD_routine_size();
int get_SAVE_routine_size();

//STACK_ADD generate_full_stack_addition(REGS regs, const enum file_type type);

void generate_AF_stack_addition(STACK_ADD* stack_add, REGS* regs, const enum file_type type, bool add_pc);

void generate_LOAD_routine(alt_u8* routine, REGS regs, const enum file_type type);
void generate_SAVE_routine(alt_u8* routine, const enum file_type type);

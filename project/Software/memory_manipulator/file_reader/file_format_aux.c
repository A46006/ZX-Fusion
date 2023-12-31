#include "../file_reader/file_format_aux.h"

#include "../file_reader/asm_opcodes.h"
#include "../file_reader/mem_addrs.h"

alt_u16 conv_data_8_16(alt_u8* data, int offset) {
	return ((data[offset] << 8) & 0xFF00) | (data[offset+1]);
}

alt_u16 reverse_16(alt_u16 data) {
	return (data << 8) | (data >> 8);
}

alt_u16 conv_data_8_16_sep(alt_u8 data_l, alt_u8 data_h) {
	return (data_h << 8) | data_l;
}

int get_LOAD_routine_size() {
	return 46;
}

int get_SAVE_routine_size() {
	return 54;
}

//////////////////////////////////////
// Gonna change method of loading regs
// Using the stack!
// Must generate data to write to stack area
// based on routine order:
//
// SP is decremented for each push
//
// For TAP, SP has PC in it already, so must make that distinction
//
// Skip this step for TAP files: SP--; PC&0xFF00 >> 8; SP--; PC&0xFF
//
// Since Interrupt mode and EI/DI must be saved, this will come in 1 byte:
//          7  6  5  4  3  2  1  0
//         EI             IM IM IM
// Occupying IM with 3 bits instead of 2 so a simple BIT check can be done
// instead of arithmetic. Also I have extra space
//
// With this value: SP--; write(SP, INT)
//
// STILL IMPORTANT TO SEND THE SP SOMEHOW (according to a yt video, 5B00 to 5CCA is reserved for BASIC, so maybe safe?)
//
// IX and IY next: write(--SP, IX&0xFF; write(--SP, (IX >> 8))); ... same with IY
// AF: write(--SP, A); write(--SP, F)
// BC: write(--SP, B); write(--SP, C)
// DE: write(--SP, D); write(--SP, E)
// HL: write(--SP, H); write(--SP, L)
// ...
//
// There is NO DIRECT POP TO R AND I so must POP SOMEWHERE ELSE AND LD
// POP BC (B = I and C = R)

// Stack:
// border
// R
// I
// L'
// H'
// E'
// D'
// C'
// B'
// F'
// A'
// L
// H
// E
// D
// C
// B
// F
// A
// IY -> ( IY  low)
//       ( IY high)
// IX -> ( IX  low)
//       ( IX high)
// INT
// PC (manual if !.SNA)

/*
STACK_ADD generate_full_stack_addition(REGS regs, const enum file_type type) {
	//alt_u16 sp = regs.SP;
	size_t size = 0;
	alt_u8 data[30];

	// Filling the stack data from the end to the start (top to bottom)
	data[size++] = regs.border;
	data[size++] = regs.border; // can only POP 16 bits at a time, so just filling this
	data[size++] = regs.R;
	data[size++] = regs.I;
	data[size++] = regs.Ll;
	data[size++] = regs.Hl;
	data[size++] = regs.El;
	data[size++] = regs.Dl;
	data[size++] = regs.Cl;
	data[size++] = regs.Bl;
	data[size++] = regs.Fl;
	data[size++] = regs.Al;

	data[size++] = regs.IY >> 8;	// Low byte
	data[size++] = regs.IY & 0xFF;	// High Byte

	data[size++] = regs.IX >> 8;	// Low byte
	data[size++] = regs.IX & 0xFF;	// High Byte

	// Since Interrupt mode and EI/DI must be saved, this will come in this byte:
	//          7  6  5  4  3  2  1  0
	//         EI             IM IM IM
	alt_u8 interrupt_info = 0;
	if (regs.IFF1 != 0) {
		// EI
		interrupt_info = 0x80;
	}
	// IM
	interrupt_info |= (1 << regs.IM);

	data[size++] = interrupt_info;
	data[size++] = interrupt_info; // again, can only pop 16bit values, so repeating this one

	data[size++] = regs.L;
	data[size++] = regs.H;
	data[size++] = regs.E;
	data[size++] = regs.D;
	data[size++] = regs.C;
	data[size++] = regs.B;
	data[size++] = regs.F;
	data[size++] = regs.A;

	if (type != SNA) {
		data[size++] = regs.PC >> 8; // Low byte
		data[size++] = regs.PC & 0xFF; // High byte
	}

	STACK_ADD to_ret = {
		.SP = regs.SP - size,
		.size = size,
		.data = *data
	};
	return to_ret;
}
*/

void generate_AF_stack_addition(STACK_ADD* stack_add, REGS* regs, const enum file_type type, bool add_pc) {
	size_t size = 0;
	//memset(to_ret.data, 0, 10);
	//to_ret.data = (alt_u8*) malloc(10*sizeof(char*));

	stack_add->data[size++] = regs->Fl;
	stack_add->data[size++] = regs->Al;
	//printf("AF': 0x%04x\r\n", (regs.Fl <<8) | regs.Al);

	stack_add->data[size++] = regs->F;
	stack_add->data[size++] = regs->A;
	//printf("AF: 0x%04x\r\n", (regs.F <<8) | regs.A);

	if (add_pc) {
		stack_add->data[size++] = regs->PC >> 8;
		stack_add->data[size++] = regs->PC & 0xFF;
		//printf("PC: 0x%04x\r\n", regs.PC);
	}

	stack_add->SP = regs->SP - (size << 8); // since this is in little endian, must subtract this value instead of just size
	//printf("STACK POINTER in STACK_ADD: 0x%04x\r\n", to_ret.SP);
	stack_add->size = size;
}

void generate_LOAD_routine(alt_u8* routine, REGS regs, const enum file_type type) {
	short i = 0;

	// R Register is for RAM refresh, so it might be ok without this...
	// Load R data into A
	routine[i++] = LD_A_N;
	routine[i++] = regs.R;

	// Load contents of A (R data) into R
	routine[i++] = LD_x_A;
	routine[i++] = LD_R_A;

	// Load I data into A
	routine[i++] = LD_A_N;
	routine[i++] = regs.I;

	// Load contents of A (I data) into I
	routine[i++] = LD_x_A;
	routine[i++] = LD_I_A;


	// Load contents of A AUX into A
	//routine[i++] = LD_A_N;
	//routine[i++] = regs.Al;

	// MISSING FLAGS, BECAUSE CAN'T FIND OPCODE FOR LOADING FLAGS REG (pretty sure there is none)
	// ALSO MISSING WAY OF SETTING IFF2 (not important?)

	// Load HL DE and BC with AUX version values
	routine[i++] = LD_HL_NN;
	routine[i++] = regs.Ll;
	routine[i++] = regs.Hl;

	routine[i++] = LD_DE_NN;
	routine[i++] = regs.El;
	routine[i++] = regs.Dl;

	routine[i++] = LD_BC_NN;
	routine[i++] = regs.Cl;
	routine[i++] = regs.Bl;

	// Exchange AUX value regs with normal
	routine[i++] = EXX;
	//routine[i++] = EX_AF;


	// Loads HL contents to HL
	routine[i++] = LD_HL_NN;
	routine[i++] = regs.L;
	routine[i++] = regs.H;

	// Loads DE contents to DE
	routine[i++] = LD_DE_NN;
	routine[i++] = regs.E;
	routine[i++] = regs.D;

	// Loads BC contents to BC
	routine[i++] = LD_BC_NN;
	routine[i++] = regs.C;
	routine[i++] = regs.B;

	// Load contents of A into A
	//routine[i++] = LD_A_N;
	//routine[i++] = regs.A;

	// Load contents of IY into IY
	routine[i++] = LD_IY1_NN;
	routine[i++] = LD_IY2_NN;
	routine[i++] = regs.IY >> 8;	// already in little endian
	routine[i++] = regs.IY & 0xFF;

	// Load contents of IX into IX
	routine[i++] = LD_IX1_NN;
	routine[i++] = LD_IX2_NN;
	routine[i++] = regs.IX >> 8;
	routine[i++] = regs.IX & 0xFF;

	// Load contents of SP into SP
	routine[i++] = LD_SP_NN;
	alt_u16 sp = regs.SP;
	if (type != SNA) {
		sp = sp - 0x200; // For the PC that I will add to the stack
	}
	//printf("SP in routine: %04x\r\n", sp);
	sp -= 0x400;
	//printf("SP in routine: %04x\r\n", sp);
	routine[i++] = sp >> 8;//(sp >> 8) - 4;//(regs.SP >> 8) - 4; // setting sp for AF' and AF in it
	routine[i++] = sp & 0xFF;

	routine[i++] = POP_AF;  // AF = AF'
	routine[i++] = EX_AF;   // AF <--> AF'
	routine[i++] = POP_AF;  // AF = AF

	// Set Interrupt mode
	routine[i++] = IM_x;
	alt_u8 interrupt_mode = regs.IM;
	switch (interrupt_mode) {
		case 0:
			routine[i++] = IM_0;
			break;
		case 1:
			routine[i++] = IM_1;
			break;
		case 2:
			routine[i++] = IM_2;
			break;
		default:
			printf("Wrong interrupt byte... defaulting to 1");
			routine[i++] = IM_1;
	}

	if (regs.IFF2) {
		routine[i++] = EI;
	} else {
		routine[i++] = DI;
	}

//	printf("REGS:\r\n");
//	printf("|PC: %04X\t\tSP: %04X\r\n", regs.PC, regs.SP);
//	printf("|AF: %04X\t\tAF': %04X\r\n", ((regs.F << 8) & 0xFF00) | regs.A, ((regs.Fl << 8) & 0xFF00) | regs.Al);
//	printf("|BC: %04X\t\tBC': %04X\r\n", ((regs.C << 8) & 0xFF00) | regs.B, ((regs.Cl << 8) & 0xFF00) | regs.Bl);
//	printf("|DE: %04X\t\tDE': %04X\r\n", ((regs.E << 8) & 0xFF00) | regs.D, ((regs.El << 8) & 0xFF00) | regs.Dl);
//	printf("|HL: %04X\t\tHL': %04X\r\n", ((regs.L << 8) & 0xFF00) | regs.H, ((regs.Ll << 8) & 0xFF00) | regs.Hl);
//	printf("|IX: %04X\t\tIY: %04X\r\n", regs.IX, regs.IY);
//	printf("|I: %02X\t\tR: %02X\r\n", regs.I, regs.R);

//	routine[i++] = DI;
//	routine[i++] = HALT_ASM;
	routine[i++] = RETN1;
	routine[i++] = RETN2;
}

void generate_SAVE_routine(alt_u8* routine, const enum file_type type) {
	int i = 0;

	// when NMI is triggered, PC will be in stack. IT IS VITAL TO KNOW SP AND PC

	// Save SP somewhere known
	// SP can be stored after the NMI code, like in 0x4100. This is in range of the first block, which can be used to "fix" the screen later

	// store SP value to SP_ADDR (LD (ADDR), SP)
	routine[i++] = LD_NN_dd;
	routine[i++] = LD_NN_SP2;
	routine[i++] = SP_ADDR_L;
	routine[i++] = SP_ADDR_H;

	// IDEA: overwrite NMI code with the values themselves as the instructions execute
	// NEXT: the AF registers should be saved ASAP. Unfortunately, they don't have a LD instruction, only a PUSH.
	routine[i++] = PUSH_AF;
	routine[i++] = EX_AF;
	routine[i++] = PUSH_AF;

	// STACK now: --> AF', AF, PC, ...

	// each register is now written to video memory:

	// HL saving
	routine[i++] = LD_NN_HL;
	routine[i++] = HL_ADDR_L;
	routine[i++] = HL_ADDR_H;

	// BC saving
	routine[i++] = LD_NN_dd;
	routine[i++] = LD_NN_BC2;
	routine[i++] = BC_ADDR_L;
	routine[i++] = BC_ADDR_H;

	// DE saving
	routine[i++] = LD_NN_dd;
	routine[i++] = LD_NN_DE2;
	routine[i++] = DE_ADDR_L;
	routine[i++] = DE_ADDR_H;

	// switch between AUX registers
	routine[i++] = EXX;

	// HL' saving
	routine[i++] = LD_NN_HL;
	routine[i++] = HL_AUX_ADDR_L;
	routine[i++] = HL_AUX_ADDR_H;

	// BC' saving
	routine[i++] = LD_NN_dd;
	routine[i++] = LD_NN_BC2;
	routine[i++] = BC_AUX_ADDR_L;
	routine[i++] = BC_AUX_ADDR_H;

	// DE' saving
	routine[i++] = LD_NN_dd;
	routine[i++] = LD_NN_DE2;
	routine[i++] = DE_AUX_ADDR_L;
	routine[i++] = DE_AUX_ADDR_H;

	// IX saving
	routine[i++] = LD_NN_IX1;
	routine[i++] = LD_NN_IX2;
	routine[i++] = IX_ADDR_L;
	routine[i++] = IX_ADDR_H;

	// IY saving
	routine[i++] = LD_NN_IY1;
	routine[i++] = LD_NN_IY2;
	routine[i++] = IY_ADDR_L;
	routine[i++] = IY_ADDR_H;

	// I saving
	routine[i++] = LD_A_I1;
	routine[i++] = LD_A_I2;
	routine[i++] = LD_NN_A;
	routine[i++] = I_ADDR_L;
	routine[i++] = I_ADDR_H;

	// R saving
	routine[i++] = LD_A_R1;
	routine[i++] = LD_A_R2;
	routine[i++] = LD_NN_A;
	routine[i++] = R_ADDR_L;
	routine[i++] = R_ADDR_H;

	// ALL registers now saved on screen. Interrupt info missing

	// No way of obtaining current interrupt info, so using default values based on how ZX Spectrum works:
	// Interrupt Mode: 1; IFF1: 0

	alt_u16 sp = 0x5800;
	routine[i++] = LD_SP_NN;
	routine[i++] = sp & 0xFF;
	routine[i++] = sp >> 8;

	// Command to "notify" NIOS that the register values are there
	routine[i++] = IN_A_N;
	routine[i++] = STATE_IF;
	
	routine[i++] = HALT_ASM;

	// LENGTH OF CODE UNTIL NOW: 54
}


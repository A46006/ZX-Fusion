// 8-bit loads
#define LD_A_N 0x3E  // Load N into reg A
#define LD_NN_HL 0x22 // Load into memory address (NN) contents of A

#define LD_x_A 0xED // Load into I/R contents of A (first byte)
#define LD_I_A 0x47 // Load contents of A into I (second byte)
#define LD_R_A 0x4F // Load contents of A into R (second byte)

#define LD_NN_A 0x32 // Load into (NN) contents of A
#define LD_A_I1 0xED // Part 1 of loading contents of I into A
#define LD_A_I2 0x57 // Part 2 of loading contents of I into A
#define LD_A_R1 0xED // Part 1 of loading contents of R into A
#define LD_A_R2 0x5F // Part 2 of loading contents of R into A

// 16-bit loads
#define LD_HL_NN 0x21
#define LD_DE_NN 0x11
#define LD_BC_NN 0x01
#define LD_SP_NN 0x31
#define LD_IY1_NN 0xFD
#define LD_IY2_NN 0x21
#define LD_IX1_NN 0xDD
#define LD_IX2_NN 0x21

#define LD_NN_dd 0xED
#define LD_NN_SP2 0x73
#define LD_NN_BC2 0x43
#define LD_NN_DE2 0x53

#define LD_NN_HL 0x22

#define LD_NN_IX1 0xDD
#define LD_NN_IX2 0x22
#define LD_NN_IY1 0xFD
#define LD_NN_IY2 0x22


#define EXX 0xD9	// Exchance BC, DE and HL for aux versions
#define EX_AF 0x08	// Exchange AF for aux AF

#define IM_x 0xED // Set Interruption mode to x (first byte)
#define IM_0 0x46 // Set Interruption mode to 0 (second byte)
#define IM_1 0x56 // Set Interruption mode to 1 (second byte)
#define IM_2 0x5E // Set Interruption mode to 2 (second byte)

#define RETN1 0xED // Return from NMI (first byte)
#define RETN2 0x45 // Return from NMI (first byte)

#define EI 0xFB // enable interrupt
#define DI 0xF3 // disable interrupt

#define JP_NN 0xC3

#define POP_AF 0xF1

#define PUSH_AF 0xF5

#define IN_A_N 0xDB
#define STATE_IF 0x19 // save state interface

#define HALT_ASM 0x76

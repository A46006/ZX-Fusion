// 8-bit loads
#define LD_A_N 0x3E  // Load N into reg A
#define LD_NN_HL 0x22 // Load into memory address (NN) contents of A

#define LD_x_A 0xED // Load into I/R contents of A (first byte)
#define LD_I_A 0x47 // Load contents of A into I (second byte)
#define LD_R_A 0x4F // Load contents of A into R (second byte)

// 16-bit loads
#define LD_HL_NN 0x21
#define LD_DE_NN 0x11
#define LD_BC_NN 0x01
#define LD_SP_NN 0x31
#define LD_IY1_NN 0xFD
#define LD_IY2_NN 0x21
#define LD_IX1_NN 0xDD
#define LD_IX2_NN 0x21


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

#include "../file_reader/file_format_aux.h"
#include "../file_reader/mem_addrs.h"
#include "../spectrum_control_IFs/DMA/dma_hal.h"
#include "../terasic_lib/terasic_includes.h"
#include "..\SD\sd_if.h"

/* *******************
 * .SNA format
 * *******************/
#define SNA_OFFSET_I 0x00
#define SNA_OFFSET_HL_AUX 0x01
//#define SNA_OFFSET_L_AUX 0x01
//#define SNA_OFFSET_H_AUX 0x02
#define SNA_OFFSET_DE_AUX 0x03
//#define SNA_OFFSET_E_AUX 0x03
//#define SNA_OFFSET_D_AUX 0x04
#define SNA_OFFSET_BC_AUX 0x05
//#define SNA_OFFSET_C_AUX 0x05
//#define SNA_OFFSET_B_AUX 0x06
//#define SNA_OFFSET_AF_AUX 0x07
#define SNA_OFFSET_F_AUX 0x07
#define SNA_OFFSET_A_AUX 0x08
#define SNA_OFFSET_HL 0x09
//#define SNA_OFFSET_L 0x09
//#define SNA_OFFSET_H 0x0A
#define SNA_OFFSET_DE 0x0B
//#define SNA_OFFSET_E 0x0B
//#define SNA_OFFSET_D 0x0C
#define SNA_OFFSET_BC 0x0D
//#define SNA_OFFSET_C 0x0D
//#define SNA_OFFSET_B 0x0E
#define SNA_OFFSET_IY 0x0F
#define SNA_OFFSET_IX 0x11
#define SNA_OFFSET_IFF2 0x13
#define SNA_OFFSET_R 0x14
//#define SNA_OFFSET_AF 0x15
#define SNA_OFFSET_F 0x15
#define SNA_OFFSET_A 0x16
#define SNA_OFFSET_SP 0x17
#define SNA_OFFSET_INT_MODE 0x19
#define SNA_OFFSET_BORDER 0x1A
#define SNA_OFFSET_DATA 0x1B


/* *******************
 * .z80 format
 * *******************/
/* HEADER 1 */
#define Z80_OFFSET_A 0
#define Z80_OFFSET_F 1
#define Z80_OFFSET_C 2
#define Z80_OFFSET_B 3
#define Z80_OFFSET_L 4
#define Z80_OFFSET_H 5
#define Z80_OFFSET_PC 6
#define Z80_OFFSET_SP 8
#define Z80_OFFSET_I 10
#define Z80_OFFSET_R 11
#define Z80_OFFSET_FLAGS1 12
#define Z80_OFFSET_E 13
#define Z80_OFFSET_D 14

#define Z80_OFFSET_C_AUX 15
#define Z80_OFFSET_B_AUX 16
#define Z80_OFFSET_E_AUX 17
#define Z80_OFFSET_D_AUX 18
#define Z80_OFFSET_L_AUX 19
#define Z80_OFFSET_H_AUX 20
#define Z80_OFFSET_A_AUX 21
#define Z80_OFFSET_F_AUX 22

#define Z80_OFFSET_IY 23
#define Z80_OFFSET_IX 25

#define Z80_OFFSET_INT_FF 27
#define Z80_OFFSET_IFF2 28
#define Z80_OFFSET_FLAGS2 29

#define Z80_OFFSET_DATA_H1 30

/* FLAGS BYTE MASKS */
#define MASK_FLAGS1_R7(x) 	  x & 0b00000001
#define MASK_FLAGS1_BORDER(x) (x & 0b00001110) >> 1
#define MASK_FLAGS1_COMPRESSED(x) x & 0b00100000

#define MASK_FLAGS2_IM(x) x & 0b00000011

/* HEADER 2 (v2) */
#define Z80_OFFSET_H2_LEN 30
#define Z80_OFFSET_PC_H2 32
#define Z80_OFFSET_HW 34
// byte 35 seems not necessary in this situation (48k only)
// byte 36 has FF if Interface I rom is paged (no paging here, so not needed I THINK)
// byte 37 other stuff
// byte 38 last out to soundchip reg number
// offset 39 contents of sound chip regs
#define Z80_OFFSET_DATA_H2_v2 55

/* HEADER 2 (extra v3 only data) */
// word 55 low T state counter ?
// byte 57 hi T state counter
// byte 58 Spectator emulator flag byte
// byte 59 FF if MGT rom paged
// byte 60 FF if multiface rom paged
// byte 61 FF if 0-8191 is ROM, 0 if RAM ???
// byte 62 FF if 8192-16383 is ROM, 0 if RAM ???
// offset 63 5 x keyboard mappings for user defined joystick
// offset 73 5 x ASCII word: keys corresponding to mappings above
// byte 83 MGT type: 0=Disciple+Epson,1=Disciple+HP,16=Plus D
// byte 84 Disciple inhibit button status: 0=out, 0ff=in
// byte 85 Disciple inhibit flag: 0=rom pageable, 0ff=not
#define Z80_OFFSET_OUT_1FFD 86
#define Z80_OFFSET_DATA_H2_v3 86 // DATA if length = 54

/* Hardware mode */
#define HW_48K 0
#define HW_48K_IF1 1
#define HW_48K_SAMRAM 2
// ...

/* ENUM for keeping track of compression*/
// ZERO for detecting end marker (00 ED ED 00)
// Despite ED ED 00 never being possible except for that marker, the first 00 doesn't count as data
// so it must be ignored when writing data
enum comp_state { NONE, ZERO, ED1, ED2, XX };

#define DATA_BLOCK_HEADER_SIZE 3

int load_file(char* filename, int name_len);

/* SNA */
REGS generate_regs_SNA(alt_u8* data);
int load_SNA(char* filename);
void fill_sna_header(alt_u8* buffer, REGS* regs);
int save_SNA(char* filename);

/* Z80 */
int get_version_z80(alt_u8* data);
bool is_48k(alt_u8* data, int version);
bool is_compressed(alt_u8* data);
alt_u16 get_addr_from_page(alt_u8 page);
//DATA_BLOCK_HEADER get_current_block_head(alt_u8* data, int offset, enum data_header_state state);
alt_u8 get_data_offset(alt_u8* data, int version);
REGS generate_regs_z80(alt_u8* data, int version);
alt_u16 load_compressed_data_block_z80(alt_u16 addr, alt_u8* buffer, int data_offset, int nReadSize);
int load_z80(char* filename);

/* SAVE STATE */
REGS generate_regs_save_state();

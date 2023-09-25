// --------------------------------------------------------------------
// Copyright (c) 2009 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#ifndef SD_PROTOCOL_H_
#define SD_PROTOCOL_H_

#define SD_4BIT_MODE

void SD_Init(void);
bool SD_IsSupport4Bits(void);

// Command
void SD_CMD0(void);
bool SD_CMD8(alt_u8 VolId, alt_u8 TestPattern);
bool SD_CMD55(alt_u16 RCA16, alt_u8 ExpectedState);
bool SD_ACMD41(alt_u32 HostOCR32, alt_u32 *pOCR32);
bool SD_CMD2(alt_u8 szCID[], int nBufLen);
bool SD_CMD3(alt_u16 *pRCA16);
bool SD_CMD9(alt_u16 RCA16, alt_u8 szCSD[], int nBufLen);
bool SD_CMD10(alt_u16 RCA16, alt_u8 szCID[], int nBufLen);
bool SD_CMD7(alt_u16 RCA16);
bool SD_CMD16(alt_u32 BlockSize);
bool SD_ACMD6(bool b4BitsBus, alt_u8 ExpectedState);
bool SD_ACMD42(bool bSetCardDetect, alt_u8 ExpectedState);
bool SD_CMD17(alt_u32 Addr, alt_u8 ExpectedStatus);
bool SD_CMD24(alt_u32 Addr, alt_u8 ExpectedStatus);

// Data
bool SD_ReadData(alt_u8 szBuf[], int nBufLen);
bool SD_WriteData(alt_u8 szDataWrite[], int nDataLen);

// Voltage Supplied (VHS)
#define SD_VHS_2V7_3V6              0x01


#define CMD8_DEFAULT_TEST_PATTERN   0xAA

typedef enum{
    SD_STATE_IDLE = 0,
    SD_STATE_READY = 1,    
    SD_STATE_IDENT = 2,
    SD_STATE_STBY = 3,
    SD_STATE_TRAN    
}SD_CURRENT_STATE;

#endif /*SD_PROTOCOL_H_*/


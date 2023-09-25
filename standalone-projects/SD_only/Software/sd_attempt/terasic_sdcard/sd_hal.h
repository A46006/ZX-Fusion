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

#ifndef SD_HAL_H_
#define SD_HAL_H_

void SDHAL_Init(void);
bool SDHAL_IsSupport4Bits(void);
void SDHAL_SendCmd(alt_u8 szCommand[6], int nCmdLen);
bool SDHAL_GetResponse(alt_u8 szResponse[], int nLen);
bool SDHAL_ReadData(alt_u8 szBuf[], int nBufLen);
bool SDHAL_WriteData(alt_u8 szDataWrite[], int nDataLen);
void SDHAL_DummyClock(int nClockCnt);

#endif /*SD_HAL_H_*/

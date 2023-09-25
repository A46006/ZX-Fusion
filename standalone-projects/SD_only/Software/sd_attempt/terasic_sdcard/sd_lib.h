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

#ifndef SD_CARD_LIB_H_
#define SD_CARD_LIB_H_

#include "..\terasic_lib\terasic_includes.h"




bool SDLIB_Init(void);
bool SDLIB_ReadBlock512(alt_u32 block_number, alt_u8 *buff);
bool SDLIB_WriteBlock512(alt_u32 block_number, alt_u8 szDataWrite[]);
//bool SD_GetCSD(alt_u8 szCSD[], alt_u8 len);
//bool SD_GetCID(alt_u8 szCID[], alt_u8 len);


#endif /*SD_CARD_LIB_H_*/

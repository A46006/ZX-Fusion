// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
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

#include "..\terasic_lib\terasic_includes.h"
#include "sd_hal.h"
#include "sd_hw.h"
#include "crc16.h"


bool SDHAL_IsSupport4Bits(void){
    bool bYes = FALSE;
#ifdef SD_4BIT_MODE
    bYes = TRUE;
#endif    
    return bYes;
}

void SDHAL_Init(void){
    SD_CMD_OUT;
    SD_DAT_IN;
    SD_CLK_HIGH;
    SD_CMD_HIGH;
    SD_DAT_LOW;    
}

void SDHAL_SendCmd(alt_u8 szCommand[6], int nCmdLen){

    int i, k;
    alt_u8 Mask, Data;
    
    SD_CMD_OUT;
    for(i=0;i<nCmdLen;i++){
        Mask = 0x80;
        Data = szCommand[i];
        for(k=0;k<8;k++){
            SD_CLK_LOW;
            if (Data & Mask)
                SD_CMD_HIGH;
            else
                SD_CMD_LOW;
            SD_CLK_HIGH;    
            //    
            Mask >>= 1;
           // usleep(1);
        }
    }
}




bool SDHAL_GetResponse(alt_u8 szResponse[], int nLen){
    bool bDone, bTimeout;
    const int nMaxCnt = 20; // !!!! Note. the value should be large than 8
    int nCnt, nBitCnt, nIndex;
    alt_u8 Value;
    

    SD_CMD_IN;
    
    //===== check start bit == 0
    nCnt = 0;
    bDone = FALSE;
    bTimeout = FALSE;
    while(!bDone && !bTimeout){
        SD_CLK_LOW;
        SD_CLK_HIGH;
        if(!(SD_TEST_CMD))
            bDone = TRUE;
        else if(nCnt++ > nMaxCnt)
            bTimeout = TRUE;
    }
    
    if (!bDone || bTimeout)
        return FALSE;
  
    //===== check transmitter bit == 0

    SD_CLK_LOW;
    SD_CLK_HIGH;
    if (SD_TEST_CMD)
        return FALSE;   // 0 is expected

    
    //===== read content + CRC + end-bits ======
    nIndex = 2;
    nBitCnt = nLen*8;
    bDone = FALSE;
    Value = 0;
    while(nIndex < nBitCnt){
        SD_CLK_LOW;
        SD_CLK_HIGH;
        if (SD_TEST_CMD){
            Value |= 0x80 >> (nIndex % 8);
        }
        if (nIndex%8 == 7){
            szResponse[nIndex/8] = Value;
            Value = 0;
        }
        nIndex++;
    } 
    
    // A command with response. 8 clocks after the card response end bit.
    SDHAL_DummyClock(8);
    
    return TRUE;
}


bool SDHAL_ReadData(alt_u8 szBuf[], int nBufLen){
    bool bSuccess = TRUE;
    int nTry = 0;
    const int nMaxTry = 5000; 
    int i, j,k,n=0;   
    alt_u8  DataTemp;
    alt_u8 Data8;
 
#ifndef SD_4BIT_MODE     
    alt_u16 DataCrc16, MyCrc16;
    
#else
    alt_u8  szBuf_0[128],szBuf_1[128],szBuf_2[128],szBuf_3[128];
    
    alt_u16 DataCrc16_0,DataCrc16_1,DataCrc16_2,DataCrc16_3;
    alt_u16 MyCrc16_0,MyCrc16_1,MyCrc16_2,MyCrc16_3;
    
    alt_u8 Data8_0,Data8_1,Data8_2,Data8_3;
    
#endif    
    
    SD_DAT_IN;
    
    // wait start bits (zero)
    while(1){
      SD_CLK_LOW;
      SD_CLK_HIGH;
#ifdef SD_4BIT_MODE
      if((SD_TEST_DAT & 0x0F) == 0x00) // check start bits (zero is expected)
#else      
      if((SD_TEST_DAT & 0x01) == 0x00) // check start bits (zero is expected)
#endif      
        break;
      if (nTry++ > nMaxTry)
        return FALSE;        
    }     
    
    // read data (512byte = 1 block)
    
#ifdef SD_4BIT_MODE
     for(i=0;i<nBufLen/4;i++)
     {
        k = 0;
        Data8   = 0;
        Data8_0 = 0;
        Data8_1 = 0;
        Data8_2 = 0;
        Data8_3 = 0;
        
        for(j=0;j<8;j++)
        {
          SD_CLK_LOW;
          SD_CLK_HIGH;
          Data8   <<= 4;
          Data8_0 <<= 1;
          Data8_1 <<= 1;
          Data8_2 <<= 1;
          Data8_3 <<= 1; 
          
          DataTemp = SD_TEST_DAT;
          Data8   |= (DataTemp & 0x0F);
          Data8_0 |= (DataTemp & 0x01);
          Data8_1 |= ((DataTemp >> 1) & 0x01);
          Data8_2 |= ((DataTemp >> 2) & 0x01);
          Data8_3 |= ((DataTemp >> 3) & 0x01);
          
          k++;
          if(k == 2)
          {
            szBuf[n++] = Data8;
            Data8 = 0;
            k = 0;
          }
        } 
        szBuf_0[i] = Data8_0;
        szBuf_1[i] = Data8_1;
        szBuf_2[i] = Data8_2;
        szBuf_3[i] = Data8_3;
     } 
#else   
    for(i=0;i<nBufLen;i++)  //512byte
    {
      Data8 = 0;   
      for(j=0;j<8;j++)
      {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        Data8 <<= 1; 
        
        if(SD_TEST_DAT & 0x01)  // check bit0
            Data8 |= 0x01;
      }
      szBuf[i]=Data8; 
    }
#endif

    //===== CRC16 and end-bit check (each channel is seperated)
#ifdef SD_4BIT_MODE 
    // Not implement yet
    DataCrc16_0 = 0;
    DataCrc16_1 = 0;
    DataCrc16_2 = 0;
    DataCrc16_3 = 0;
    for(i=0;i<16;i++)
    {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        
        DataCrc16_0 <<= 1;
        DataCrc16_1 <<= 1;
        DataCrc16_2 <<= 1;
        DataCrc16_3 <<= 1;
        
        DataTemp = SD_TEST_DAT;
        
        if (DataTemp & 0x01)
            DataCrc16_0 |= 0x01;
         if(DataTemp & 0x02)
            DataCrc16_1 |= 0x01;
         if(DataTemp & 0x04)
            DataCrc16_2 |= 0x01;
         if(DataTemp & 0x08)
            DataCrc16_3 |= 0x01;
    }
    
    // check end bit (value 'one' is expected
    SD_CLK_LOW;
    SD_CLK_HIGH;
    if ((SD_TEST_DAT & 0x0F) != 0x0F)
        bSuccess = FALSE;
     
    // to provide8 (eight) clock cycles for the card to complete the operation before shutting down the clock 
    SDHAL_DummyClock(8);     
     
    // check crc    
    if (bSuccess){
        MyCrc16_0 = crc16(szBuf_0, nBufLen/4);
        if (MyCrc16_0 != DataCrc16_0)
            bSuccess = FALSE;
    }    
    if (bSuccess){
        MyCrc16_1 = crc16(szBuf_1, nBufLen/4);
        if (MyCrc16_1 != DataCrc16_1)
            bSuccess = FALSE;
    }   
    if (bSuccess){
        MyCrc16_2 = crc16(szBuf_2, nBufLen/4);
        if (MyCrc16_2 != DataCrc16_2)
            bSuccess = FALSE;
    } 
    if (bSuccess){
        MyCrc16_3 = crc16(szBuf_3, nBufLen/4);
        if (MyCrc16_3 != DataCrc16_3)
            bSuccess = FALSE;
    } 
#else
    // read rcr
    DataCrc16 = 0;
    for(i=0;i<16;i++){
        SD_CLK_LOW;
        SD_CLK_HIGH;
        DataCrc16 <<= 1;
        
        if (SD_TEST_DAT & 0x01)
            DataCrc16 |= 0x01;
    }
    
    // check end bit (value 'one' is expected
    SD_CLK_LOW;
    SD_CLK_HIGH;
    if ((SD_TEST_DAT & 0x01) != 0x01)
        bSuccess = FALSE;
     
    // to provide8 (eight) clock cycles for the card to complete the operation before shutting down the clock 
    SDHAL_DummyClock(8);     
     
    // check crc    
    if (bSuccess){
        MyCrc16 = crc16(szBuf, nBufLen);
        if (MyCrc16 != DataCrc16)
            bSuccess = FALSE;
    }            
    
#endif

    return bSuccess;
}

bool SDHAL_WriteData(alt_u8 szDataWrite[], int nDataLen){
    bool bSuccess = TRUE;
  //  int nTry = 0;
  //  const int nMaxTry = 5000; 
    int i, j;   
    alt_u8 Data8;
    alt_u16 DataCrc16;
    
    DataCrc16 = crc16(szDataWrite, nDataLen);
    
    /*
    // wait ready
    while(1){
      SD_CLK_LOW;
      SD_CLK_HIGH;
      if((SD_TEST_DAT & 0x01) == 0x00) // check bit0 
        break;
      if (nTry++ > nMaxTry)
        return FALSE;        
    } */    
    
    SD_DAT_OUT;
    // start bits (zero value)
    SD_CLK_LOW;
    SD_DAT_WRITE(0x00);  
    SD_CLK_HIGH;
    
    // write data (512byte = 1 block)
    for(i=0;i<nDataLen;i++)
    {
      Data8 = szDataWrite[i];
#ifdef SD_4BIT_MODE
      for(j=0;j<2;j++)
      {
        SD_CLK_LOW;
        //
        SD_DAT_WRITE((Data8 >> 4) & 0x0F);
        //            
        SD_CLK_HIGH;
        Data8 <<= 4; 
      } 
#else      
      for(j=0;j<8;j++)
      {
        SD_CLK_LOW;
        //
        if (Data8 & 0x80)
            SD_DAT_HIGH;
        else
            SD_DAT_LOW;
        //    
        SD_CLK_HIGH;
        Data8 <<= 1; 
      } 
#endif  

        
    }
    
#ifdef SD_4BIT_MODE
    // not implement yet
#else    
    
    // send CRC
    for(i=0;i<16;i++){
        SD_CLK_LOW;
        if (DataCrc16 & 0x8000)
            SD_DAT_HIGH;
        else
            SD_DAT_LOW;
        //    
        SD_CLK_HIGH;
        DataCrc16 <<= 1;         
    }
    
    

    
#endif    

    // stop bits (value 'one')
    SD_CLK_LOW;
#ifdef SD_4BIT_MODE
    SD_DAT_WRITE(0x0F);
#else    
    SD_DAT_HIGH;
#endif     
    SD_CLK_HIGH;
    
    //===== check busy bits (data0 only)
    SD_DAT_IN;
bool bWriteSuccess = FALSE;    
for(i=0;i<32 && !bWriteSuccess;i++){        
    SD_CLK_LOW;
    SD_CLK_HIGH;
    if ((SD_TEST_DAT & 0x01) == 0x01) // (DAT0==LOW: busy indicate
        bWriteSuccess = TRUE;
}
    if (!bWriteSuccess)
        bSuccess = FALSE;
                
    // to provide8 (eight) clock cycles for the card to complete the operation before shutting down the clock 
    SDHAL_DummyClock(8);     

    /*
    //
    for(i=0; i<16; i++){
        SD_CLK_LOW;
        SD_CLK_HIGH;
    }*/
    
    return bSuccess;
    
}


void SDHAL_DummyClock(int nClockCnt){
    int i;
    for(i=0;i<nClockCnt;i++){
        SD_CLK_LOW;
        SD_CLK_HIGH;
    }
}



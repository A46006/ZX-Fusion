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
// Last built by: Quartus 9.1 SP2 build 350
// Supported File Format: FAT16 & FAT 32
// Supported SDCARD: SD, HCSD

#include <stdio.h>
#include ".\terasic_fat\FatFileSystem.h"
#include "..\terasic_lib\terasic_includes.h"


bool Fat_Test(FAT_HANDLE hFat, char *pDumpFile){
    bool bSuccess;
    int nCount = 0;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;

    bSuccess = Fat_FileBrowseBegin(hFat, &hBrowse);
	printf("LIST %d\r\n", bSuccess);
    if (bSuccess){
    	printf("AAAA\r\n");
        while(Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                alt_u16 *pData16;
                alt_u8 *pData8;
                pData16 = (alt_u16 *)FileContext.szName;
                pData8 = FileContext.szName;
                printf("[%d]", nCount);
                while(*pData16){
                    if (*pData8)
                        printf("%c", *pData8);
                    pData8++;
                    if (*pData8)
                        printf("%c", *pData8);
                    pData8++;
                    //
                    pData16++;
                }
                printf("\n");
            }else{
                printf("[%d]%s\n", nCount, FileContext.szName);
            }
            nCount++;
        }
    }
    if (bSuccess && pDumpFile && strlen(pDumpFile)){
        FAT_FILE_HANDLE hFile;
        hFile =  Fat_FileOpen(hFat, pDumpFile);
        if (hFile){
            alt_u8 szRead[256];
            int nReadSize, nFileSize, nTotalReadSize=0;
            nFileSize = Fat_FileSize(hFile);
            if (nReadSize > sizeof(szRead))
                nReadSize = sizeof(szRead);
            printf("%s dump:\n", pDumpFile);
            while(bSuccess && nTotalReadSize < nFileSize){
                nReadSize = sizeof(szRead);
                if (nReadSize > (nFileSize - nTotalReadSize))
                    nReadSize = (nFileSize - nTotalReadSize);
                //
                if (Fat_FileRead(hFile, szRead, nReadSize)){
                    int i;
                    int l = 0;
                    for(i=0;i<16;i++){
                        //printf("%c", szRead[i]);
                    	printf("0x%x ", szRead[i]);
                    	if (l++ == 16) {
                            printf("\r\n");
                            l = 0;
                        };
                    }
                    nTotalReadSize += nReadSize;
                }else{
                    bSuccess = FALSE;
                    printf("\nFailed to read the file \"%s\"\n", pDumpFile);
                }
            } // while
            if (bSuccess)
                printf("\n");
            Fat_FileClose(hFile);
        }else{
            bSuccess = FALSE;
            printf("Cannot find the file \"%s\"\n", pDumpFile);
        }
    }

    return bSuccess;
}


int SD_Test(char* file) {
    FAT_HANDLE hFat;

    printf("========== DE2-115 SDCARD Demo ==========\n");

    //while(1){
        printf("Processing...\r\n");
        hFat = Fat_Mount(FAT_SD_CARD, 0);
        if (hFat){
            printf("sdcard mount success!\n");
            printf("Root Directory Item Count:%d\n", Fat_FileCount(hFat));
            //Fat_Test(hFat, "text.txt");
            Fat_Test(hFat, file);
            Fat_Unmount(hFat);

            printf("===== Test Done =====\r\nPress KEY3 to test again.\r\n");
        }else{
            //printf("Failed to mount the SDCARD!\r\nPlease insert the SDCARD into DE2-115 board and press KEY3.\r\n");
        	printf("Failed to mount the SDCARD!\r\nPlease insert the SDCARD into DE2-115 board and reset.\r\n");
        }
        // wait users to press BUTTON3
        //while ((IORD_ALTERA_AVALON_PIO_DATA(KEY_BASE) & 0x08) == 0x08);
        usleep(400*1000); // debounce
    //} // while


  return 0;
}

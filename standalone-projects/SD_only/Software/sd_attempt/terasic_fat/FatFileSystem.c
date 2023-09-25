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
// History:
//     V 2.0.0 11/25/2009
//          - support SDHC (SDCARD large than 4G)
//          - speed up
//
//     04/03/2008
//        1. add new export api: Fat_Type
//     03/05/2008
//        1. bug fix for the function fatComposeShortFilename
//     01/10/2008
//        1.add "vol_id" detect for filename
//        2.add long filename support
//        3.add byte_per_sector=512 limitation 
//     11/200/2007, richard bug fix, Cluster is not inited in Fat_FileRead

#include <string.h> // memcpy
#include "..\terasic_lib\terasic_includes.h"
#include "FatFileSystem.h"
#include "FatInternal.h"


#ifdef DEBUG_FAT
    #define FAT_DEBUG(x)    {DEBUG(x)}
#else
    #define FAT_DEBUG(x)
#endif



//VOLUME_INFO gVolumeInfo;
void fatComposeShortFilename(FAT_DIRECTORY *pDir, char *szFilename);
bool fatSameLongFilename(alt_u16 *p1, alt_u16 *p2);




FAT_HANDLE Fat_Mount(FAT_DEVICE FatDevice, DEVICE_HANDLE hUsbDisk){
    
    //Fat_Unmount();
    FAT_HANDLE hFat = 0;
    
    if (FatDevice == FAT_SD_CARD){
        #ifdef SUPPORT_SD_CARD
        hFat = fatMountSdcard();
        #endif //SUPPORT_SD_CARD
    }else if (FatDevice == FAT_USB_DISK){
        #ifdef SUPPORT_USB_DISK
        hFat = fatMountUsbDisk(hUsbDisk);
        #endif
    }  
    return hFat;      
        
}

void Fat_Unmount(FAT_HANDLE Fat){
    VOLUME_INFO *pVol = (VOLUME_INFO *)Fat;
    if (!pVol)
        return;
#ifdef FAT_READONLY      
    if (pVol->szFatTable){
        free(pVol->szFatTable);
        pVol->szFatTable = 0;
    }        
#endif //#ifdef FAT_READONLY
    pVol->bMount = FALSE;
    
    free(pVol);  
}   

FAT_TYPE Fat_Type(FAT_HANDLE Fat){
    VOLUME_INFO *pVol = (VOLUME_INFO *)Fat;
    FAT_TYPE Type = FAT_UNKNOWN;
    if (pVol){
        if (pVol->Partition_Type == PARTITION_FAT16)
            Type = FAT_FAT16;
        else if (pVol->Partition_Type == PARTITION_FAT32)
            Type = FAT_FAT32;
    }
    return Type;        
}

bool Fat_FileBrowseBegin(FAT_HANDLE hFat, FAT_BROWSE_HANDLE *pFatBrowseHandle){
    VOLUME_INFO *pVol = (VOLUME_INFO *)hFat;
    if (!pVol)
        return FALSE;
    if (!pVol->bMount)
        return FALSE;
    pFatBrowseHandle->DirectoryIndex = -1;
    pFatBrowseHandle->hFat = hFat;
    return TRUE;
}

bool Fat_FileBrowseNext(FAT_BROWSE_HANDLE *pFatBrowseHandle, FILE_CONTEXT *pFileContext){
    bool bFind = FALSE, bError=FALSE, bLongFilename = FALSE;
    int OrderValue = 0;
    FAT_DIRECTORY *pDir;
    //unsigned int nSecter, nSecterOffset,nByteOffset;
    VOLUME_INFO *pVol = (VOLUME_INFO *)pFatBrowseHandle->hFat;
    
    if (!pVol)
        return FALSE;    
    
    if (!pVol->bMount)
        return FALSE;
    
    
    do{  // search Directory Table
        pFatBrowseHandle->DirectoryIndex++;        
        pDir = fatFindDirectory(pVol,pFatBrowseHandle->DirectoryIndex);
        if (!pDir)
            bError = TRUE;
            
        if (!bError){                        
            if (fatIsValidDir(pDir) && !fatIsUnusedDir(pDir)){
                if ((pDir->Attribute & ATTR_LONG_NAME) == ATTR_LONG_NAME){
                    FAT_LONG_DIRECTORY *pLDIR = (FAT_LONG_DIRECTORY *)pDir;
                    // check attribute
                    if ((pLDIR->LDIR_Attr & ATTR_LONG_NAME) != ATTR_LONG_NAME){
                        bError = TRUE;
                    }else{                        
                        // check order
                        if (OrderValue == 0){
                            // last entry
                            if (bLongFilename || ((OrderValue & LAST_LONG_ENTRY) != OrderValue))
                                bError = TRUE;
                            else
                                OrderValue = pLDIR->LDIR_Ord & 0x3F;
                            memset(pFileContext->szName, 0, sizeof(pFileContext->szName));        
                        }else{
                            if ((pLDIR->LDIR_Ord & 0x3F) != OrderValue)
                                bError = TRUE;
                        }
                    }
                    
                    //                        
                    if (!bError){
                        int BaseOffset;
                        bLongFilename = TRUE;
                        OrderValue--;
                        BaseOffset = OrderValue * 26;
                        // cast filename
                        memcpy(pFileContext->szName+BaseOffset, pLDIR->LDIR_Name1, 10);
                        memcpy(pFileContext->szName+BaseOffset+10, pLDIR->LDIR_Name2, 12);
                        memcpy(pFileContext->szName+BaseOffset+22, pLDIR->LDIR_Name3, 4);
                    }                        
                }else{
                    if (bLongFilename){
                        pFileContext->Attribute = ATTR_LONG_NAME;
                        if ((pDir->Attribute & (ATTR_ARCHIVE | ATTR_DIRECTORY)) == 0)
                            bError = TRUE;
                        else    
                            bFind = TRUE;
                    }else{
                        fatComposeShortFilename(pDir, pFileContext->szName);
                        bFind = TRUE;
                    }
                    
                    if (bFind){
                        // my ext
                        pFileContext->bLongFilename = bLongFilename;
                        pFileContext->bFile = (pDir->Attribute & ATTR_ARCHIVE)?TRUE:FALSE;
                        pFileContext->bDirectory = (pDir->Attribute & ATTR_DIRECTORY)?TRUE:FALSE;
                        pFileContext->bVolume = (pDir->Attribute & ATTR_VOLUME_ID)?TRUE:FALSE;
                        pFileContext->DirEntryIndex = pFatBrowseHandle->DirectoryIndex; // add in v2.0.0
                        
                        //
                        pFileContext->Attribute = pDir->Attribute;
                        pFileContext->CreateTime = pDir->CreateTime;
                        pFileContext->LastAccessDate = pDir->LastAccessDate;
                        pFileContext->FirstLogicalClusterHi = pDir->FirstLogicalClusterHi;
                        pFileContext->LastWriteTime = pDir->LastWriteTime;
                        pFileContext->LastWriteDate = pDir->LastWriteDate;
                        pFileContext->FirstLogicalCluster = pDir->FirstLogicalCluster;
                        pFileContext->FileSize = pDir->FileSize;
                    }                        
                }                    
            }                
        }            
    }while (!bFind && !fatIsLastDir(pDir) && !bError);
    
    return bFind;
    
}


unsigned int Fat_FileCount(FAT_HANDLE Fat){
    unsigned int nCount = 0;
    FAT_BROWSE_HANDLE hBrowse;
    FILE_CONTEXT FileContext;
    
    if (Fat_FileBrowseBegin(Fat, &hBrowse)){
        while(Fat_FileBrowseNext(&hBrowse, &FileContext))
            nCount++;
    }
    
    return nCount;
}

bool fatSameLongFilename(alt_u16 *p1, alt_u16 *p2){
    bool bSame = TRUE;
    
    while(bSame && ((*p1 != 0) || (*p2 != 0))){
        if (*p1 != *p2){
            bSame = FALSE;
        }
        p1++;
        p2++;
        
    }
    
    return bSame;
}


void fatComposeShortFilename(FAT_DIRECTORY *pDir, char *szFilename){
    int i,nPos=0;
    
    i=0;
    while(i < 8 && pDir->Name[i] != 0 && pDir->Name[i] != ' ')
        szFilename[nPos++] = pDir->Name[i++];
    
    if (pDir->Attribute & (ATTR_ARCHIVE | ATTR_DIRECTORY)){
        if (pDir->Attribute & (ATTR_ARCHIVE | ATTR_DIRECTORY))     
            szFilename[nPos++] = '.';   
        i=0;
        while(i < 3 && pDir->Extension[i] != 0 && pDir->Extension[i] != ' ')
            szFilename[nPos++] = pDir->Extension[i++];
    }            
    szFilename[nPos++] = 0;
}





bool Fat_FileExist(FAT_HANDLE Fat, const char *pFilename){
    bool bFind = FALSE;
    FAT_BROWSE_HANDLE hBrowse;     
    FILE_CONTEXT FileContext;
    if (Fat_FileBrowseBegin(Fat, &hBrowse)){
        while (!bFind && Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                bFind = fatSameLongFilename((alt_u16 *)FileContext.szName, (alt_u16 *)pFilename);
            }else{
                if (strcmpi(FileContext.szName, pFilename) == 0)
                    bFind = TRUE;
            }    
        } // while 
        Fat_FileClose(Fat); 
    }
    return bFind;            
}    
 
// File Access
FAT_FILE_HANDLE Fat_FileOpen(FAT_HANDLE Fat, const char *pFilename){
    bool bFind = FALSE;
    FAT_BROWSE_HANDLE hBrowse;     
    FILE_CONTEXT FileContext;
    FAT_FILE_INFO *pFile = 0;
    
    if (Fat_FileBrowseBegin(Fat, &hBrowse)){
        while (!bFind && Fat_FileBrowseNext(&hBrowse, &FileContext)){
            if (FileContext.bLongFilename){
                bFind = fatSameLongFilename((alt_u16 *)FileContext.szName, (alt_u16 *)pFilename);
            }else{
                if (strcmpi(FileContext.szName, pFilename) == 0)
                    bFind = TRUE;
            }    
        } // while 
        
        if (bFind){
            pFile = malloc(sizeof(FAT_FILE_INFO));
            if (pFile){
                pFile->OpenAttribute = FILE_OPEN_READ; 
                pFile->SeekPos = 0;
                pFile->Directory = FileContext;
                pFile->IsOpened = TRUE;
                pFile->Cluster = FileContext.FirstLogicalCluster;
                pFile->ClusterSeq = 0;
                pFile->Fat = Fat;
            }    
        }    
    }  

    
    return (FAT_FILE_HANDLE)pFile;  
}


unsigned int Fat_FileSize(FAT_FILE_HANDLE hFileHandle){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    if (f->IsOpened)
        return f->Directory.FileSize;
    return 0;        
}


bool Fat_FileRead(FAT_FILE_HANDLE hFileHandle, void *pBuffer, const int nBufferSize){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    VOLUME_INFO *pVol;
    alt_u32 Pos, PhysicalSecter, NextCluster, Cluster;
    alt_u32 BytesPerCluster, nReadCount=0, nClusterSeq;
    int s;
    bool bSuccess= TRUE;
    
    if (!f || !f->Fat)
        return FALSE;
    pVol = (VOLUME_INFO *)f->Fat;        
    
    if (!f->IsOpened){
        FAT_DEBUG(("[FAT] Fat_FileRead, file not opened\r\n"));
        return bSuccess;
    }        
        
    BytesPerCluster = pVol->nBytesPerCluster; //gVolumeInfo.BPB_BytsPerSec * gVolumeInfo.BPB_SecPerCluster;  
    Pos = f->SeekPos;
    if (BytesPerCluster == 32768){
        nClusterSeq = Pos >> 15;
        Pos -= (f->ClusterSeq << 15);
    }else if (BytesPerCluster == 16384){
        nClusterSeq = Pos >> 14;
        Pos -= (f->ClusterSeq << 14);
    }else if (BytesPerCluster == 2048){
        nClusterSeq = Pos >> 11;
        Pos -= (f->ClusterSeq << 11);
    }else{        
        nClusterSeq = Pos/BytesPerCluster;
        Pos -= f->ClusterSeq*BytesPerCluster;
    }    
        
       
    Cluster = f->Cluster;
    if (nClusterSeq != f->ClusterSeq){
        Cluster = f->Cluster;  //11/20/2007, richard
        // move to first clustor for reading
        while (Pos >= BytesPerCluster && bSuccess){
            // go to next cluster
            NextCluster = fatNextCluster(pVol, Cluster); 
            if (NextCluster == 0){
                bSuccess = FALSE;
                FAT_DEBUG(("[FAT] Fat_FileRead, no next Cluster, current Cluster=%d\r\n", Cluster));
            }else{
                Cluster = NextCluster;
            }        
            Pos -= BytesPerCluster;
            f->Cluster = Cluster;
            f->ClusterSeq++; 
        }
    }            
    
    // reading
    while(nReadCount < nBufferSize && bSuccess){
        if (pVol->BPB_SecPerCluster == 32)
            PhysicalSecter = ((Cluster-2) << 5) + pVol->DataEntrySecter; // -2: FAT0 & FAT1 are reserved
        else if (pVol->BPB_SecPerCluster == 64)
            PhysicalSecter = ((Cluster-2) << 6) + pVol->DataEntrySecter; // -2: FAT0 & FAT1 are reserved
        else
            PhysicalSecter = (Cluster-2)*pVol->BPB_SecPerCluster + pVol->DataEntrySecter; // -2: FAT0 & FAT1 are reserved
        for(s=0;s<pVol->BPB_SecPerCluster && nReadCount < nBufferSize && bSuccess;s++){
            if (Pos >= pVol->BPB_BytsPerSec){
                Pos -= pVol->BPB_BytsPerSec;
            }else{
                // read secter data
                bSuccess = fatReadSecter(pVol, PhysicalSecter);
                
                if (bSuccess){
                    // copy data to user buffer
                
                    int nCopyCount;
                    nCopyCount = pVol->BPB_BytsPerSec;
                    if (Pos)
                        nCopyCount -= Pos;
                    if (nCopyCount > (nBufferSize-nReadCount))
                        nCopyCount = nBufferSize-nReadCount;
                    if (nCopyCount == 512){
                        memcpy((char *)pBuffer+nReadCount, pVol->Secter_Data, 512);
                        nReadCount += nCopyCount;
                        if (Pos > 0)
                            Pos = 0;
                    }else{
                        memcpy((void *)((char *)pBuffer+nReadCount), pVol->Secter_Data+Pos,nCopyCount);
                        nReadCount += nCopyCount;
                        if (Pos > 0)
                            Pos = 0;
                    }         
                }    // if bSuccess
                    
            }
            PhysicalSecter++;
        }    
            
        // next cluster
        if (nReadCount < nBufferSize){
            NextCluster = fatNextCluster(pVol, Cluster); 
            if (NextCluster == 0){
                bSuccess = FALSE;
                FAT_DEBUG(("[FAT] Fat_FileRead, no next cluster\r\n"));
            }else{
                Cluster = NextCluster;
            }    
            //    
            f->ClusterSeq++; 
            f->Cluster = Cluster;
        }                    
    }
    
    if (bSuccess){
        f->SeekPos += nBufferSize;
    }        
        
    
    return bSuccess;
}


bool Fat_FileSeek(FAT_FILE_HANDLE hFileHandle, const FAT_SEEK_POS SeekPos, const int nOffset){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    VOLUME_INFO *pVol;
    bool bSuccess= TRUE;

    if (!f || !f->Fat)
        return FALSE;
    pVol = (VOLUME_INFO *)f->Fat;        
    
    if (!f->IsOpened)
        return FALSE;
        
    switch(SeekPos){
        case FILE_SEEK_BEGIN: 
            f->SeekPos = nOffset; 
            break;
        case FILE_SEEK_CURRENT: 
            f->SeekPos += nOffset; 
            break;
        case FILE_SEEK_END: 
            f->SeekPos = f->Directory.FileSize+nOffset; 
            break;
        default:
            bSuccess = FALSE;
            break;    
              
    }
    f->Cluster = f->Directory.FirstLogicalCluster;
    f->ClusterSeq = 0;
    
    return bSuccess;
    
}

void Fat_FileClose(FAT_FILE_HANDLE hFileHandle){
    FAT_FILE_INFO *f = (FAT_FILE_INFO *)hFileHandle;
    if (!f)
        return;
        
    free(f);        
}



float Fat_SpeedTest(FAT_HANDLE hFat, alt_u32 TestDurInMs){
    bool bSuccess = TRUE;
    alt_u32 time_start, time_finish, time_elapsed, TotalReadBytes=0;
    int nSecter = 0;
    float fMegaBytePerSec = 0;
    char szBlock[512];
    VOLUME_INFO *pVol = (VOLUME_INFO *)hFat;
    if (!pVol)
        return 0;
    time_start = alt_nticks();
    time_finish = alt_nticks() + TestDurInMs * 1000 / alt_ticks_per_second();
    while(alt_nticks() < time_finish && bSuccess){
        bSuccess = pVol->ReadBlock512(pVol->DiskHandle, nSecter, szBlock);
        nSecter++;
        TotalReadBytes += sizeof(szBlock);
        
    }        
    if (bSuccess){
        time_elapsed = alt_nticks() - time_start;
        fMegaBytePerSec = (float)TotalReadBytes * (float)alt_ticks_per_second() / (float)time_elapsed / 1024.0 / 1024.0;
    }        
    return fMegaBytePerSec;
    
   
}


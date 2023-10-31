/*------------------------------------------------------------------------/
/  Foolproof MMCv3/SDv1/SDv2 (in SPI mode) control module
/-------------------------------------------------------------------------/
/
/  Copyright (C) 2019, ChaN, all right reserved.
/
/ * This software is a free software and there is NO WARRANTY.
/ * No restriction on use. You can use, modify and redistribute it for
/   personal, non-profit or commercial products UNDER YOUR RESPONSIBILITY.
/ * Redistributions of source code must retain the above copyright notice.
/
/-------------------------------------------------------------------------/
  Features and Limitations:

  * Easy to Port Bit-banging SPI
    It uses only four GPIO pins. No complex peripheral needs to be used.

  * Platform Independent
    You need to modify only a few macros to control the GPIO port.

  * Low Speed
    The data transfer rate will be several times slower than hardware SPI.

  * No Media Change Detection
    Application program needs to perform a f_mount() after media change.

/-------------------------------------------------------------------------*/


#include "ff.h"		/* Obtains integer types for FatFs */
#include "diskio.h"	/* Common include file for FatFs and disk I/O layer */

#include "..\..\terasic_lib\terasic_includes.h"

// SD Card Output
#define SD_CLK_LOW  {									\
		/*usleep(10);*/										\
		IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 0);	\
}

#define SD_CLK_HIGH  {									\
		/*usleep(10);*/										\
		IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1);	\
}

// Chip select (active-low)
#define SD_CS_ENABLE  IOWR_ALTERA_AVALON_PIO_DATA(SD_CS_BASE, 0)
#define SD_CS_DISABLE IOWR_ALTERA_AVALON_PIO_DATA(SD_CS_BASE, 1)
// Data
#define SD_MOSI_LOW  IOWR_ALTERA_AVALON_PIO_DATA(SD_MOSI_BASE, 0)
#define SD_MOSI_HIGH IOWR_ALTERA_AVALON_PIO_DATA(SD_MOSI_BASE, 1)

// SD Card Input
#define SD_READ_MISO  IORD_ALTERA_AVALON_PIO_DATA(SD_MISO_BASE)


/*--------------------------------------------------------------------------

   Module Private Functions

---------------------------------------------------------------------------*/

/* MMC/SD command (SPI mode) */
#define CMD0	(0)			/* GO_IDLE_STATE */
#define CMD1	(1)			/* SEND_OP_COND */
#define	ACMD41	(0x80+41)	/* SEND_OP_COND (SDC) */
#define CMD8	(8)			/* SEND_IF_COND */
#define CMD9	(9)			/* SEND_CSD */
#define CMD10	(10)		/* SEND_CID */
#define CMD12	(12)		/* STOP_TRANSMISSION */
#define CMD13	(13)		/* SEND_STATUS */
#define ACMD13	(0x80+13)	/* SD_STATUS (SDC) */
#define CMD16	(16)		/* SET_BLOCKLEN */
#define CMD17	(17)		/* READ_SINGLE_BLOCK */
#define CMD18	(18)		/* READ_MULTIPLE_BLOCK */
#define CMD23	(23)		/* SET_BLOCK_COUNT */
#define	ACMD23	(0x80+23)	/* SET_WR_BLK_ERASE_COUNT (SDC) */
#define CMD24	(24)		/* WRITE_BLOCK */
#define CMD25	(25)		/* WRITE_MULTIPLE_BLOCK */
#define CMD32	(32)		/* ERASE_ER_BLK_START */
#define CMD33	(33)		/* ERASE_ER_BLK_END */
#define CMD38	(38)		/* ERASE */
#define CMD55	(55)		/* APP_CMD */
#define CMD58	(58)		/* READ_OCR */


DSTATUS Stat = STA_NOINIT;	/* Disk status */

BYTE CardType;			/* b0:MMC, b1:SDv1, b2:SDv2, b3:Block addressing */



// initializes the spi module
void spi_init() {
	SD_CS_DISABLE;
	SD_CLK_LOW;
	SD_MOSI_HIGH;

}

/*
// writes a byte to spi bus
*/
void spi_write(alt_u8 data) {
	alt_u8 mask = 0x80;
	for (int i = 0; i < 8; i++) {
		SD_CLK_LOW;
		if (data & mask)
			SD_MOSI_HIGH;
		else
			SD_MOSI_LOW;
		SD_CLK_HIGH;
		mask >>= 1;
	}
	SD_CLK_LOW;
}


// writes a buffer to the spi bus
// data while writing
void spi_write_buffer(const alt_u8* data, int length) {
	while(length--) {
		spi_write(*data++);
	}
}

// reads a byte to spi bus
alt_u8 spi_read() {
	alt_u8 data = 0;
	for (int i = 0; i<8; i++) {
        SD_CLK_LOW;
        SD_CLK_HIGH;
        if (SD_READ_MISO)
        	data |= 0x80 >> (i % 8);
	}
	return data;
}

void spi_read_buffer(alt_u8* buffer, int length) {
	while(length--)
		*buffer++ = spi_read();
}




/*-----------------------------------------------------------------------*/
/* Wait for card ready                                                   */
/*-----------------------------------------------------------------------*/

int wait_ready (void)	/* 1:OK, 0:Timeout */
{
	BYTE d;
	UINT tmr;


	for (tmr = 5000; tmr; tmr--) {	/* Wait for ready in timeout of 500ms */
		d = spi_read();
		if (d == 0xFF) break;
		usleep(100);
	}

	return tmr ? 1 : 0;
}



/*-----------------------------------------------------------------------*/
/* Deselect the card and release SPI bus                                 */
/*-----------------------------------------------------------------------*/

void deselect (void)
{
	BYTE d;

	spi_write(0xFF);
	SD_CS_DISABLE;				/* Set CS# high */
	spi_write(0xFF);
}



/*-----------------------------------------------------------------------*/
/* Select the card and wait for ready                                    */
/*-----------------------------------------------------------------------*/

int select (void)	/* 1:OK, 0:Timeout */
{
	BYTE d;

	spi_write(0xFF);
	SD_CS_ENABLE;				/* Set CS# low */
	spi_write(0xFF);
	if (wait_ready()) return 1;	/* Wait for card ready */

	deselect();
	return 0;			/* Failed */
}



/*-----------------------------------------------------------------------*/
/* Receive a data packet from the card                                   */
/*-----------------------------------------------------------------------*/

int rcvr_datablock (	/* 1:OK, 0:Failed */
	BYTE *buff,			/* Data buffer to store received data */
	UINT btr			/* Byte count */
)
{
	BYTE d[2];
	UINT tmr;


	for (tmr = 1000; tmr; tmr--) {	/* Wait for data packet in timeout of 100ms */
		d[0] = spi_read();// rcvr_mmc(d, 1);
		if (d[0] != 0xFF) break;
		usleep(100);
	}
	if (d[0] != 0xFE) return 0;		/* If not valid data token, return with error */

	spi_read_buffer(buff, btr);		/* Receive the data block into buffer */
	//rcvr_mmc(buff, btr);
	spi_read_buffer(d, 2);			/* Discard CRC */

	return 1;						/* Return with success */
}



/*-----------------------------------------------------------------------*/
/* Send a data packet to the card                                        */
/*-----------------------------------------------------------------------*/

int xmit_datablock (	/* 1:OK, 0:Failed */
	const BYTE *buff,	/* 512 byte data block to be transmitted */
	BYTE token			/* Data/Stop token */
)
{
	BYTE d[2];


	if (!wait_ready()) return 0;

	d[0] = token;
	spi_write(d[0]);					/* Xmit a token */
	if (token != 0xFD) {				/* Is it data token? */
		spi_write_buffer(buff, 512);	/* Xmit the 512 byte data block to MMC */
		spi_read_buffer(d, 2);			/* Xmit dummy CRC (0xFF,0xFF) */
		d[0] = spi_read();				/* Receive data response */
		if ((d[0] & 0x1F) != 0x05)		/* If not accepted, return with error */
			return 0;
	}

	return 1;
}



/*-----------------------------------------------------------------------*/
/* Send a command packet to the card                                     */
/*-----------------------------------------------------------------------*/

BYTE send_cmd (		/* Returns command response (bit7==1:Send failed)*/
	BYTE cmd,		/* Command byte */
	DWORD arg		/* Argument */
)
{
	BYTE n, d;


	if (cmd & 0x80) {	/* ACMD<n> is the command sequense of CMD55-CMD<n> */
		cmd &= 0x7F;
		n = send_cmd(CMD55, 0);
		if (n > 1) return n;
	}

	/* Select the card and wait for ready except to stop multiple block read */
	if (cmd != CMD12) {
		deselect();
		if (!select()) return 0xFF;
	}

	/* Send a command packet */
	spi_write((0x40 | cmd));
	spi_write((BYTE)(arg >> 24));
	spi_write((BYTE)(arg >> 16));
	spi_write((BYTE)(arg >> 8));
	spi_write((BYTE) arg);
	if (cmd == CMD0) {
		spi_write(0x95);
	} else if (cmd == CMD8) {
		spi_write(0x87);
	} else {
		spi_write(0x01);
	}

	/* Receive command response */
	if (cmd == CMD12) spi_read();/* Skip a stuff byte when stop reading */
	n = 0xFF;							/* Wait for a valid response in timeout of 255 attempts */
	do {
		d = spi_read();
	} while ((d & 0x80) && --n);

	return d;			/* Return with the response value */
}



/*--------------------------------------------------------------------------

   Public Functions

---------------------------------------------------------------------------*/


/*-----------------------------------------------------------------------*/
/* Get Disk Status                                                       */
/*-----------------------------------------------------------------------*/


DSTATUS MMC_disk_status (
	//BYTE drv			// Drive number (always 0)
)
{
	//if (drv) return STA_NOINIT;

	return Stat;
}



/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/


DSTATUS MMC_disk_initialize (
	//BYTE drv		// Physical drive number (0)
)
{
	BYTE n, ty, cmd, buf[4];
	UINT tmr;
	DSTATUS s;


	// New generation cards APPARENTLY fail to enter Idle state with CMD0 unless
	// they get 3 seconds of wait time after powering up. Newer off brand cards do, but older ones don't
	usleep(3000000);

	usleep(10000);			// 10ms
	SD_CS_DISABLE;		// Initialize port pin tied to CS
	SD_CLK_LOW;			// Initialize port pin tied to SCLK
	SD_MOSI_HIGH;		// data out high

	SD_CS_ENABLE;
	for (n = 10; n; n--) spi_write(0xFF);	// Apply 80 dummy clocks and the card gets ready to receive command
	// send 16 clock pulses to the card
	spi_write(0xFF);
	spi_write(0xFF);

	ty = 0;
	if (send_cmd(CMD0, 0) == 1) {			// Enter Idle state
		if (send_cmd(CMD8, 0x1AA) == 1) {	// SDv2?
			spi_read_buffer(buf, 4);					// Get trailing return value of R7 resp
			if (buf[2] == 0x01 && buf[3] == 0xAA) {		// The card can work at vdd range of 2.7-3.6V
				for (tmr = 1000; tmr; tmr--) {			// Wait for leaving idle state (ACMD41 with HCS bit)
					n = send_cmd(ACMD41, 0x50000000);
					if (n == 0) break;
					usleep(1000);
				}
				if (tmr && send_cmd(CMD58, 0) == 0) {	// Check CCS bit in the OCR
					spi_read_buffer(buf, 4);
					ty = (buf[0] & 0x40) ? CT_SDC2 | CT_BLOCK : CT_SDC2;	// SDv2+
				}
			}
		} else {							// SDv1 or MMCv3
			if (send_cmd(ACMD41, 0) <= 1) 	{
				ty = CT_SDC2; cmd = ACMD41;	// SDv1
			} else {
				ty = CT_MMC3; cmd = CMD1;	// MMCv3
			}
			for (tmr = 1000; tmr; tmr--) {			// Wait for leaving idle state
				if (send_cmd(cmd, 0) == 0) break;
				usleep(1000);
			}
			if (!tmr || send_cmd(CMD16, 512) != 0)	// Set R/W block length to 512
				ty = 0;
		}
	}
	CardType = ty;
	s = ty ? 0 : STA_NOINIT;
	Stat = s;

	deselect();

	printf("init STAT: %d\r\n", s);

	return s;
}



/*-----------------------------------------------------------------------*/
/* Read Sector(s)                                                        */
/*-----------------------------------------------------------------------*/

DRESULT MMC_disk_read (
	BYTE *buff,			/* Pointer to the data buffer to store read data */
	LBA_t sector,		/* Start sector number (LBA) */
	UINT count			/* Sector count (1..128) */
)
{
	BYTE cmd;
	DWORD sect = (DWORD)sector;


	if (!(CardType & CT_BLOCK)) sect *= 512;	/* Convert LBA to byte address if needed */

	cmd = count > 1 ? CMD18 : CMD17;			/*  READ_MULTIPLE_BLOCK : READ_SINGLE_BLOCK */
	if (send_cmd(cmd, sect) == 0) {
		do {
			if (!rcvr_datablock(buff, 512)) break;
			buff += 512;
		} while (--count);
		if (cmd == CMD18) send_cmd(CMD12, 0);	/* STOP_TRANSMISSION */
	}
	deselect();

	return count ? RES_ERROR : RES_OK;
}



/*-----------------------------------------------------------------------*/
/* Write Sector(s)                                                       */
/*-----------------------------------------------------------------------*/

DRESULT MMC_disk_write (
	//BYTE drv,			// Physical drive nmuber (0)
	const BYTE *buff,	// Pointer to the data to be written
	LBA_t sector,		// Start sector number (LBA)
	UINT count			// Sector count (1..128)
)
{
	DWORD sect = (DWORD)sector;


	//if (disk_status(drv) & STA_NOINIT) return RES_NOTRDY;
	if (!(CardType & CT_BLOCK)) sect *= 512;	//Convert LBA to byte address if needed

	if (count == 1) {	// Single block write
		if ((send_cmd(CMD24, sect) == 0)	// WRITE_BLOCK
			&& xmit_datablock(buff, 0xFE))
			count = 0;
	}
	else {				// Multiple block write
		if (CardType & CT_SDC) send_cmd(ACMD23, count);
		if (send_cmd(CMD25, sect) == 0) {	// WRITE_MULTIPLE_BLOCK
			do {
				if (!xmit_datablock(buff, 0xFC)) break;
				buff += 512;
			} while (--count);
			if (!xmit_datablock(0, 0xFD))	// STOP_TRAN token
				count = 1;
		}
	}
	deselect();

	return count ? RES_ERROR : RES_OK;
}


/*-----------------------------------------------------------------------*/
/* Miscellaneous Functions                                               */
/*-----------------------------------------------------------------------*/

DRESULT MMC_disk_ioctl (
	//BYTE drv,		// Physical drive nmuber (0)
	BYTE ctrl,		/* Control code */
	void *buff		/* Buffer to send/receive control data */
)
{
	DRESULT res;
	BYTE n, csd[16];
	DWORD cs;


	//if (disk_status(drv) & STA_NOINIT) return RES_NOTRDY;	// Check if card is in the socket

	res = RES_ERROR;
	switch (ctrl) {
		case CTRL_SYNC :		/* Make sure that no pending write process */
			if (select()) res = RES_OK;
			break;

		case GET_SECTOR_COUNT :	/* Get number of sectors on the disk (DWORD) */
			if ((send_cmd(CMD9, 0) == 0) && rcvr_datablock(csd, 16)) {
				if ((csd[0] >> 6) == 1) {	/* SDC ver 2.00 */
					cs = csd[9] + ((WORD)csd[8] << 8) + ((DWORD)(csd[7] & 63) << 16) + 1;
					*(LBA_t*)buff = cs << 10;
				} else {					/* SDC ver 1.XX or MMC */
					n = (csd[5] & 15) + ((csd[10] & 128) >> 7) + ((csd[9] & 3) << 1) + 2;
					cs = (csd[8] >> 6) + ((WORD)csd[7] << 2) + ((WORD)(csd[6] & 3) << 10) + 1;
					*(LBA_t*)buff = cs << (n - 9);
				}
				res = RES_OK;
			}
			break;

		case GET_BLOCK_SIZE :	/* Get erase block size in unit of sector (DWORD) */
			*(DWORD*)buff = 128;
			res = RES_OK;
			break;

		default:
			res = RES_PARERR;
	}

	deselect();

	return res;
}
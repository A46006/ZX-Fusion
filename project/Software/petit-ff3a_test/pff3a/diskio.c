/*-----------------------------------------------------------------------*/
/* Low level disk I/O module skeleton for Petit FatFs (C)ChaN, 2014      */
/*-----------------------------------------------------------------------*/

#include "sd.h"

static
DSTATUS Stat = STA_NOINIT;	/* Disk status */

static
BYTE CardType;			/* b0:MMC, b1:SDv1, b2:SDv2, b3:Block addressing */

// these flags weren't originally in this file, only in ffsample
/* MMC card type flags (MMC_GET_TYPE) */
#define CT_MMC3		0x01		/* MMC ver 3 */
#define CT_MMC4		0x02		/* MMC ver 4+ */
#define CT_MMC		0x03		/* MMC */
#define CT_SDC1		0x04		/* SD ver 1 */
#define CT_SDC2		0x08		/* SD ver 2+ */
#define CT_SDC		0x0C		/* SD */
#define CT_BLOCK	0x10		/* Block addressing */

/*-----------------------------------------------------------------------*/
/* Initialize Disk Drive                                                 */
/*-----------------------------------------------------------------------*/

DSTATUS disk_initialize (void)
{
	BYTE n, ty, cmd, buf[4];
	UINT tmr;
	DSTATUS s;

	// New generation cards APPARENTLY fail to enter Idle state with CMD0 unless
	// they get 3 seconds of wait time after powering up. Newer off brand cards do, but older ones don't
	usleep(3000000);

	//usleep(10000);			// 10ms
	CS_H;		// Initialize port pin tied to CS
	CLK_L;		// Initialize port pin tied to SCLK

	for (n = 10; n; n--) spi_receive(buf, 1);	// Apply 80 dummy clocks and the card gets ready to receive command

	ty = 0;
	if (send_cmd(CMD0, 0) == 1) {			// Enter Idle state
		if (send_cmd(CMD8, 0x1AA) == 1) {	// SDv2?
			spi_receive(buf, 4);							// Get trailing return value of R7 resp
			if (buf[2] == 0x01 && buf[3] == 0xAA) {		// The card can work at vdd range of 2.7-3.6V
				for (tmr = 1000; tmr; tmr--) {			// Wait for leaving idle state (ACMD41 with HCS bit)
					if (send_cmd(ACMD41, 1UL << 30) == 0) break;
					usleep(1000);
				}
				if (tmr && send_cmd(CMD58, 0) == 0) {	// Check CCS bit in the OCR
					spi_receive(buf, 4);
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

	spi_deselect();

	return s;
}



/*-----------------------------------------------------------------------*/
/* Read Partial Sector                                                   */
/*-----------------------------------------------------------------------*/

DRESULT disk_readp (
	BYTE* buff,		/* Pointer to the destination object */
	DWORD sector,	/* Sector number (LBA) */
	UINT offset,	/* Offset in the sector */
	UINT count		/* Byte count (bit15:destination) */
)
{
	if (
			(offset < 0 || offset > 511) ||
			(count < 0 || count > 512) ||
			(count+offset > 512)
		)
	{
		return RES_PARERR;
	}

	BYTE* full_buff;
	DWORD sect = (DWORD)sector;

	if (!(CardType & CT_BLOCK)) sect *= 512;	/* Convert LBA to byte address if needed */

	if (send_cmd(CMD17, sect) == 0) {
		if (spi_receive_datablock(full_buff, 512)) {
			for (int i = 0; i < count; i++) {
				buff[i] = full_buff[offset+i];
			}
			count = 0;
		}
	}
	spi_deselect();

	return count ? RES_ERROR : RES_OK;
}



/*-----------------------------------------------------------------------*/
/* Write Partial Sector                                                  */
/*-----------------------------------------------------------------------*/



DRESULT disk_writep (
	const BYTE* buff,		/* Pointer to the data to be written, NULL:Initiate/Finalize write operation */
	DWORD sc		/* Sector number (LBA) or Number of bytes to send */
)
{
	DRESULT res;
	if (sc > 512) return RES_PARERR;


	if (!buff) {
		if (sc) {

			// Initiate write process

		} else {

			// Finalize write process

		}
	} else {

		// Send data to the disk

	}

	return res;
}


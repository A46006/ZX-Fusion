#include "spi.h"

void spi_send(
		const BYTE* buff,	/* Data to be sent */
		UINT bc				/* Number of bytes to send */
)
{
	BYTE d;

	do {
		d = *buff++;	/* Get a byte to be sent */
		if (d & 0x80) DI_H; else DI_L;	/* bit7 */
		CLK_H; CLK_L;
		if (d & 0x40) DI_H; else DI_L;	/* bit6 */
		CLK_H; CLK_L;
		if (d & 0x20) DI_H; else DI_L;	/* bit5 */
		CLK_H; CLK_L;
		if (d & 0x10) DI_H; else DI_L;	/* bit4 */
		CLK_H; CLK_L;
		if (d & 0x08) DI_H; else DI_L;	/* bit3 */
		CLK_H; CLK_L;
		if (d & 0x04) DI_H; else DI_L;	/* bit2 */
		CLK_H; CLK_L;
		if (d & 0x02) DI_H; else DI_L;	/* bit1 */
		CLK_H; CLK_L;
		if (d & 0x01) DI_H; else DI_L;	/* bit0 */
		CLK_H; CLK_L;
	} while (--bc);
}

void spi_receive (
	BYTE *buff,	/* Pointer to read buffer */
	UINT bc		/* Number of bytes to receive */
)
{
	BYTE r;

	DI_H;	/* Send 0xFF */

	do {
		r = 0;	 if (DO) r++;	/* bit7 */
		CLK_H; CLK_L;
		r <<= 1; if (DO) r++;	/* bit6 */
		CLK_H; CLK_L;
		r <<= 1; if (DO) r++;	/* bit5 */
		CLK_H; CLK_L;
		r <<= 1; if (DO) r++;	/* bit4 */
		CLK_H; CLK_L;
		r <<= 1; if (DO) r++;	/* bit3 */
		CLK_H; CLK_L;
		r <<= 1; if (DO) r++;	/* bit2 */
		CLK_H; CLK_L;
		r <<= 1; if (DO) r++;	/* bit1 */
		CLK_H; CLK_L;
		r <<= 1; if (DO) r++;	/* bit0 */
		CLK_H; CLK_L;
		*buff++ = r;			/* Store a received byte */
	} while (--bc);
}

int spi_wait_ready (void)	/* 1:OK, 0:Timeout */
{
	BYTE d;
	UINT tmr;

	for (tmr = 5000; tmr; tmr--) {	/* Wait for ready in timeout of 500ms */
		spi_receive(&d, 1);
		if (d == 0xFF) break;
		usleep(100);
	}

	return tmr ? 1 : 0;
}

void spi_deselect (void)
{
	BYTE d;

	CS_H;				/* Set CS# high */
	spi_receive(&d, 1);	/* Dummy clock (force DO hi-z for multiple slave SPI) */
}

int spi_select (void)	/* 1:OK, 0:Timeout */
{
	BYTE d;

	CS_L;				/* Set CS# low */
	spi_receive(&d, 1);	/* Dummy clock (force DO enabled) */
	if (spi_wait_ready()) return 1;	/* Wait for card ready */

	spi_deselect();
	return 0;			/* Failed */
}

int spi_receive_datablock (	/* 1:OK, 0:Failed */
	BYTE *buff,			/* Data buffer to store received data */
	UINT btr			/* Byte count */
)
{
	BYTE d[2];
	UINT tmr;


	for (tmr = 1000; tmr; tmr--) {	/* Wait for data packet in timeout of 100ms */
		spi_receive(d, 1);
		if (d[0] != 0xFF) break;
		usleep(100);
	}
	if (d[0] != 0xFE) return 0;		/* If not valid data token, return with error */

	spi_receive(buff, btr);			/* Receive the data block into buffer */
	spi_receive(d, 2);					/* Discard CRC */

	return 1;						/* Return with success */
}

int spi_send_datablock (	/* 1:OK, 0:Failed */
	const BYTE *buff,	/* 512 byte data block to be transmitted */
	BYTE token			/* Data/Stop token */
)
{
	BYTE d[2];


	if (!spi_wait_ready()) return 0;

	d[0] = token;
	spi_send(d, 1);				/* Xmit a token */
	if (token != 0xFD) {		/* Is it data token? */
		spi_send(buff, 512);	/* Xmit the 512 byte data block to MMC */
		spi_receive(d, 2);			/* Xmit dummy CRC (0xFF,0xFF) */
		spi_receive(d, 1);			/* Receive data response */
		if ((d[0] & 0x1F) != 0x05)	/* If not accepted, return with error */
			return 0;
	}

	return 1;
}

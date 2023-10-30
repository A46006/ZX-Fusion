#include "..\terasic_lib\terasic_includes.h"
#include "diskio.h"

#define DO		IORD_ALTERA_AVALON_PIO_DATA(SD_MISO_BASE)

#define DI_H	IOWR_ALTERA_AVALON_PIO_DATA(SD_MOSI_BASE, 1)
#define DI_L	IOWR_ALTERA_AVALON_PIO_DATA(SD_MOSI_BASE, 0)

#define CLK_H {										\
		usleep(10);										\
		IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1);	\
}
#define CLK_L {										\
		usleep(10);										\
		IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1);	\
}

#define CS_H	IOWR_ALTERA_AVALON_PIO_DATA(SD_CS_BASE, 1)
#define CS_L	IOWR_ALTERA_AVALON_PIO_DATA(SD_CS_BASE, 0)

void spi_send(
		const BYTE* buff,	/* Data to be sent */
		UINT bc				/* Number of bytes to send */
);

void spi_receive (
	BYTE *buff,	/* Pointer to read buffer */
	UINT bc		/* Number of bytes to receive */
);

int spi_wait_ready (void);

void spi_deselect (void);

int spi_select (void);

int spi_receive_datablock (
	BYTE *buff,			/* Data buffer to store received data */
	UINT btr			/* Byte count */
);

int spi_send_datablock (
	const BYTE *buff,	/* 512 byte data block to be transmitted */
	BYTE token			/* Data/Stop token */
);

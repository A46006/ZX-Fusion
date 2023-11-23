#include "../../terasic_lib/terasic_includes.h"
#include "alt_types.h"  // alt_u32
#include "io.h"
#include "system.h"

// Control Bus (RDn, WRn, MEMREQn, IOREQn)
#define READ_SET			0x07
#define WRITE_SET			0x0B
#define MEM_REQ_SET			0x0D
#define IO_REQ_SET			0x0E

#define READ_CLR			0x08
#define WRITE_CLR			0x04
#define MEM_REQ_CLR			0x02
#define IO_REQ_CLR			0x01

#define CTRL_BUS_SET(x)		IOWR_ALTERA_AVALON_PIO_DATA(CTRL_BUS_BASE, x)

// Address Bus
#define ADDR_SET(x)			IOWR_ALTERA_AVALON_PIO_DATA(ADDRESS_BASE, x)

// Data Bus
#define DATA_IN				IOWR_ALTERA_AVALON_PIO_DIRECTION(DATA_BASE, 0x00)
#define DATA_OUT			IOWR_ALTERA_AVALON_PIO_DIRECTION(DATA_BASE, 0xFF)

#define DATA_SET(data8) 	IOWR_ALTERA_AVALON_PIO_DATA(DATA_BASE, data8)
#define DATA_GET			IORD_ALTERA_AVALON_PIO_DATA(DATA_BASE)

// NIOS to CPU
#define BUS_REQ_SET			IOWR_ALTERA_AVALON_PIO_DATA(BUS_REQ_N_BASE, 0)
#define BUS_REQ_CLR			IOWR_ALTERA_AVALON_PIO_DATA(BUS_REQ_N_BASE, 1)

#define BUS_ACK_GET			!IORD_ALTERA_AVALON_PIO_DATA(BUS_ACK_N_BASE)

#define NMI_SET				IOWR_ALTERA_AVALON_PIO_DATA(NMI_N_BASE, 0)
#define NMI_CLR				IOWR_ALTERA_AVALON_PIO_DATA(NMI_N_BASE, 1)

// Get cpu address (for after "releasing" cpu)
#define CPU_ADDR_GET		IORD_ALTERA_AVALON_PIO_DATA(CPU_ADDRESS_DIRECT_BASE)

// Get Interrupt Information (IFF2, IFF1, IM)
#define INT_INF_BASE_GET	IORD_ALTERA_AVALON_PIO_DATA(CPU_INT_INF_BASE)


#include "../../terasic_lib/terasic_includes.h"
#include "alt_types.h"  // alt_u32
#include "io.h"
#include "system.h"

// Address
#define CPU_ADDR_GET		IORD_ALTERA_AVALON_PIO_DATA(CPU_ADDRESS_BASE)

// Enable
#define EN_GET				IORD_ALTERA_AVALON_PIO_DATA(CPU_CMD_EN_BASE)

// Data in
#define CPU_CMD_GET			IORD_ALTERA_AVALON_PIO_DATA(CPU_CMD_BASE)

// Control signals
#define CPU_RD_GET			!IORD_ALTERA_AVALON_PIO_DATA(CPU_RD_N_BASE)
#define CPU_WR_GET			!IORD_ALTERA_AVALON_PIO_DATA(CPU_WR_N_BASE)

// ack
#define CMD_ACK_SET(x)		IOWR_ALTERA_AVALON_PIO_DATA(CPU_CMD_ACK_BASE, x)

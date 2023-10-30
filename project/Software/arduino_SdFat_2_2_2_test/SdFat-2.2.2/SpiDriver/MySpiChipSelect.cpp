#include "SdSpiDriver.h"
#include "..\..\terasic_lib\terasic_includes.h"

#if SD_CHIP_SELECT_MODE == 1 || SD_CHIP_SELECT_MODE == 2
//------------------------------------------------------------------------------
void sdCsInit(SdCsPin_t pin) { IOWR_ALTERA_AVALON_PIO_DATA(SD_CS_BASE, 1); }
//------------------------------------------------------------------------------
void sdCsWrite(SdCsPin_t pin, bool level) { IOWR_ALTERA_AVALON_PIO_DATA(SD_CS_BASE, level ? 1 : 0); }
#else
#error SD_CHIP_SELECT_MODE must be one or two in SdFat/SdFatConfig.h
#endif  // SD_CHIP_SELECT_MODE == 0

#include ".\SdFat-2.2.2\SdFat.h"
#include ".\SdFat-2.2.2\common\attic\MyPrint.cpp"
#include ".\SdFat-2.2.2\common\SysCall.h"
#include ".\terasic_lib\terasic_includes.h"
#include <iostream>
// SD Card Output
#define SD_CLK_LOW  {									\
		usleep(10);										\
		IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 0);	\
}

#define SD_CLK_HIGH  {									\
		usleep(10);										\
		IOWR_ALTERA_AVALON_PIO_DATA(SD_CLK_BASE, 1);	\
}


// Data
#define SD_MOSI_LOW  IOWR_ALTERA_AVALON_PIO_DATA(SD_MOSI_BASE, 0)
#define SD_MOSI_HIGH IOWR_ALTERA_AVALON_PIO_DATA(SD_MOSI_BASE, 1)

// SD Card Input
#define SD_READ_MISO  IORD_ALTERA_AVALON_PIO_DATA(SD_MISO_BASE)


// This is a simple driver based on the the standard SPI.h library.
// You can write a driver entirely independent of SPI.h.
// It can be optimized for your board or a different SPI port can be used.
// The driver must be derived from SdSpiBaseClass.
// See: SdFat/src/SpiDriver/SdSpiBaseClass.h
class MySpiClass : public SdSpiBaseClass {
 public:
  // Activate SPI hardware with correct speed and mode.
  void activate() {
	  // nothing in this case? Clocking manually
  }
  // Initialize the SPI bus.
  void begin(SdSpiConfig config) {
		//SD_CS_DISABLE;
		SD_CLK_LOW;
		SD_MOSI_HIGH;
  }
  // Deactivate SPI hardware.
  void deactivate() {
	  //SPI.endTransaction();
  }
  	// Receive a byte.
	uint8_t receive() {
		alt_u8 data = 0;
		for (int i = 0; i<8; i++) {
			SD_CLK_LOW;
			SD_CLK_HIGH;
			if (SD_READ_MISO)
				data |= 0x80 >> (i % 8);
		}
		return data;
	}
  // Receive multiple bytes.
  // Replace this function if your board has multiple byte receive.
	uint8_t receive(uint8_t* buf, size_t count) {
		while(count--)
		  *buf++ = receive();
		return 0;
		/*for (size_t i = 0; i < count; i++) {
		  buf[i] = SPI.transfer(0XFF);
		}*/
	}
  // Send a byte.
	void send(uint8_t data) {
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
  // Send multiple bytes.
  // Replace this function if your board has multiple byte send.
  void send(const uint8_t* buf, size_t count) {
    while(count--) {
    	send(*buf++);
    }
    /*for (size_t i = 0; i < count; i++) {
      SPI.transfer(buf[i]);
    }*/
  }
  // Save SPISettings for new max SCK frequency
  void setSckSpeed(uint32_t maxSck) {
    //m_spiSettings = SPISettings(maxSck, MSBFIRST, SPI_MODE0);
  }


// private:
//  SPISettings m_spiSettings;
} mySpi;

#if ENABLE_DEDICATED_SPI
#define SD_CONFIG SdSpiConfig(0, DEDICATED_SPI, SD_SCK_MHZ(50), &mySpi)
#else  // ENABLE_DEDICATED_SPI
#define SD_CONFIG SdSpiConfig(SD_CS_PIN, SHARED_SPI, SD_SCK_MHZ(50), &mySpi)
#endif  // ENABLE_DEDICATED_SPI


//------------------------------------------------------------------------------
//#include ".\SdFat-2.2.2\sdios.h"
// SD_FAT_TYPE = 0 for SdFat/File as defined in SdFatConfig.h,
// 1 for FAT16/FAT32, 2 for exFAT, 3 for FAT16/FAT32 and exFAT.
#define SD_FAT_TYPE 3
//
// Set DISABLE_CHIP_SELECT to disable a second SPI device.
// For example, with the Ethernet shield, set DISABLE_CHIP_SELECT
// to 10 to disable the Ethernet controller.
const int8_t DISABLE_CHIP_SELECT = -1;

#if SD_FAT_TYPE == 0
SdFat sd;
File file;
#elif SD_FAT_TYPE == 1
SdFat32 sd;
File32 file;
#elif SD_FAT_TYPE == 2
SdExFat sd;
ExFile file;
#elif SD_FAT_TYPE == 3
SdFs sd;
FsFile file;
#else  // SD_FAT_TYPE
#error Invalid SD_FAT_TYPE
#endif  // SD_FAT_TYPE
// Serial streams

// input buffer for line
char cinBuf[40];

// SD card chip select
int chipSelect;

void cardOrSpeed() {
  std::cout << F("Try another SD card or reduce the SPI bus speed.\n");
  std::cout << F("Edit SPI_SPEED in this program to change it.\n");
}

void reformatMsg() {
	std::cout << F("Try reformatting the card.  For best results use\n");
	std::cout << F("the SdFormatter program in SdFat/examples or download\n");
	std::cout << F("and use SDFormatter from www.sdcard.org/downloads.\n");
}

int main() {
	printf("start\r\n");
	if (DISABLE_CHIP_SELECT < 0) {
		std::cout << F(
	        "\nBe sure to edit DISABLE_CHIP_SELECT if you have\n"
	        "a second SPI device.  For example, with the Ethernet\n"
	        "shield, DISABLE_CHIP_SELECT should be set to 10\n"
	        "to disable the Ethernet controller.\n");
	  }
	std::cout << F(
	      "\nSD chip select is the key hardware option.\n"
	      "Common values are:\n"
	      "Arduino Ethernet shield, pin 4\n"
	      "Sparkfun SD shield, pin 8\n"
	      "Adafruit SD shields and modules, pin 10\n");

	  bool firstTry = true;
	  while(1) {
		  if (!firstTry) std::cout << F("\nRestarting\n");
		  firstTry = false;

		  if (DISABLE_CHIP_SELECT < 0) {
			  std::cout << F(
		  		          "\nAssuming the SD is the only SPI device.\n"
		  		          "Edit DISABLE_CHIP_SELECT to disable another device.\n");
		  }

		  if (!sd.begin(0)) {
			  if (sd.card()->errorCode()) {
				  std::cout << F(
					"\nSD initialization failed.\n"
					"Do not reformat the card!\n"
					"Is the card correctly inserted?\n"
					"Is chipSelect set to the correct value?\n"
					"Does another SPI device need to be disabled?\n"
					"Is there a wiring/soldering problem?\n");
				  std::cout << F("\nerrorCode: ");
				  std::cout << int(sd.card()->errorCode());
				  std::cout << F(", errorData: ") << int(sd.card()->errorData());
				  //std::cout << dec << noshowbase << endl;
				continue;
			  }
			  std::cout << F("\nCard bad initialize.\n");
			  if (sd.vol()->fatType() == 0) {
				  std::cout << F("Can't find a valid FAT16/FAT32 partition.\n");
				reformatMsg();
				continue;
			  }
			  std::cout << F("Can't determine error type\n");
			  continue;
		  }
		  std::cout << F("\nCard successfully initialized.\n");
		  //std::cout << endl;

		  uint32_t size = sd.card()->sectorCount();
		  if (size == 0) {
			  std::cout << F("Can't determine the card size.\n");
			  cardOrSpeed();
			  continue;
		  }
		  uint32_t sizeMB = 0.000512 * size + 0.5;
		  std::cout << F("Card size: ") << sizeMB;
		  std::cout << F(" MB (MB = 1,000,000 bytes)\n");
		  //std::cout << endl;
		  std::cout << F("Volume is FAT") << int(sd.vol()->fatType());
		  std::cout << F(", Cluster size (bytes): ") << sd.vol()->bytesPerCluster();
		  //std::cout << endl << endl;

		  std::cout << F("Files found (date time size name):\n");
		  //sd.ls(LS_R | LS_DATE | LS_SIZE);
		  //print_t a;
		  MyPrint* aaa = new MyPrint();
		  sd.ls(aaa);
		  //sd.ls(a);

		  if ((sizeMB > 1100 && sd.vol()->sectorsPerCluster() < 64) ||
		        (sizeMB < 2200 && sd.vol()->fatType() == 32)) {
			  std::cout << F("\nThis card should be reformatted for best performance.\n");
			  std::cout << F("Use a cluster size of 32 KB for cards larger than 1 GB.\n");
			  std::cout << F("Only cards larger than 2 GB should be formatted FAT32.\n");
		      reformatMsg();
		      continue;
		    }
		  std::cout << F("\nSuccess!  Looping in 10 sec.\n");
		  usleep(10000000);
	  }



	/*
  //Serial.begin(9600);
  printf("being\r\n");
  if (!sd.begin(SD_CONFIG)) {
	  printf("ERROR\r\n");
    //sd.initErrorHalt(&Serial);
  }
  printf("listing:\r\n");
  //print_t p;
  //sd.ls(&p, LS_SIZE);
  printf("done\r\n");
  */
  return 0;
}

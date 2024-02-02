# ZX-Fusion

The ZX-Fusion is an FPGA-based implementation of a ZX Spectrum 48k on a Cyclone IV chip. The target platform is the Altera DE2-115 Development Board.

# Features

This project offers:
    
- VGA video output with a resolution of 1024x768 @ 60Hz (4x native resolution of the ZX Spectrum)
    - Adjustable border size
- PS/2 keyboard input
    - US and PT layouts and numpad support
    - TODO: test native spectrum keyboard. The connections exist for the expansion board
- Audio I/O for audio output and loading cassette tapes
    - TODO: audio output for saving to a cassette tape. The stereo channels save wrong and the audio does not work when played back to load
- Joystick support
    - Two seperate ports in the expansion board
    - Toggle between Kempston and Sinclair interfaces
- SD Card support
    - A paged list menu to select between .sna and .z80 files (as long as they are for the ZX Spectrum 48k)
    - Save state support (saved as .sna files in the SD Card)
- TODO: Online support
    - Download the files and play them directly


# Information

This section describes how you can set up the implementation on an DE2-115 development board from Terasic.

## Requirements

To set up the ZX-Fusion, the following is required:

- DE2-115 board and its power cable
- USB Type B to Type A cable
- A computer with Intel Quartus Prime installed
- VGA cable and monitor
- PS/2 keynoard
- A 3.5mm audio cable M/M and a speaker
- A 3.5mm audio cable M/M and an audio cassette player or a phone
- (Optional) An SD card with .z80 or .sna files in the root directory
- (Optional) 1 or 2 serial joysticks (NES controller clones)


## Peripheral Connection

![board ports](/img/de2-115-ports.png)

- A. VGA cable port
- B. PS/2 keyboard port
- C. Audio output to connect to a speaker
- D. Audio input to connect to a cassette tape player or a smartphone
- E. SD Card slot. The slot is located under the board
- F. Pin header for connecting the expansion board

The expansion board's design files are in the "Joystick-Keyboard_Expansion_docs" folder and it is illustrated below.

![expansion](/Joystick-Keyboard_Expansion_docs/fusion-expansion-board.png)


## Powering On

To power the FPGA board, To power the FPGA board, plug the cable from the power adapter into the slot labeled "G." in the first image. Plug the power adapter to a power socket. The red button located next to the slot is the ON/OFF button. Press it once to turn on the board. An image of the board should be displayed on the connected VGA monitor, according to the initial demo that comes with the board.


## Flashing the Board

The process of flashing the board is present in its [user manual](https://www.terasic.com.tw/attachment/archive/502/DE2_115_User_manual.pdf). It is described in Chapter 4, Section 4.1 “Configuring the Cyclone IV E FPGA”.


## Board Input

![board input](/img/fusion-sw-keys.png)

1. Kempston/Sinclair toggle:
    - Down = Sinclair
    - Up = Kempston
2. Keyboard toggle:
    - Down = PS/2 Keyboard
    - Up = Native ZX Spectrum Keyboard
3. Border/Screen size:
    - Left switch down = full screen (4x native resolution) with a 1-pixel wide border
    - Left switch up = 2x native resolution
    - Both switches up = native resolution (very small!)
4. Save State Push-Button
    - Generated files have the name of the loaded software with an "_nn" suffix, with a number where "nn" is
    - If no software is loaded through a file, uses the name "save" instead.
5. Reset Push-Button


## Loading Programs

This section includes instructions for loading programs, either through the line-in port or the SD Card. On boot, if everything is ok, the main menu, illustrated below, should be displayed. 

![menu](/img/fusion-menu.jpg)

This menu can be navigated with the arrow keys and the ENTER key, as well as a joystick if it is plugged in the joystick 1 port, as long as the board is set to "Sinclair" mode. The "Online" option acts the same as the "BASIC" option as the feature is not implemented.

### From Audio Line-in

To load a program from an audio cassette or smartphone (audio source), select the “BASIC” option in the menu. This will start the original ZX Spectrum 48k’s BASIC editor. Type in LOAD "" and press enter. The border should flash red and blue. Now, start the playback of the program audio, and the border should start alternating colors. This means it is loading the program.

### From an SD Card

To load a .z80 or .sna file from an SD Card, select the first option in the main menu, “SD Loader”. This opens a new menu listing the .z80 and .sna files in your SD Card, as seen in the image below. 

![sd menu](/img/fusion-sd-menu.jpg)

Only 16 files appear per page. To change pages, press ← or → on the keyboard or joystick. When the game you want is highlighted, press the ENTER key or the FIRE button on your joystick to select the file. The program will start loading and the seven segment displays will play an animation while it loads.

Bomb Jack II can be seen running in the ZX Fusion in the image below.

![bomb jack ii](/img/fusion-bomb-jack-ii.jpg)


# Technical Information

This section describes generally how the project works and its organization. A diagram of the ZX Fusion can be seen in the following image:

![overview](/img/Detailed%20fusion%20spec.svg)

The main project files are located in the "project" folder. The root of this folder contains the "top" entity where all the components connect. It also contains:

- the reset counter used to reset all components
- a register for commands issued by the Z80 to the NIOS (explained in [SD Card Structure](#structure) section)
- a constants file used for storing constants throughout the project
    - Contains constants for US or PT keyboards. Uncomment the definitions of one and comment the other to change which one is used

The sections that follow describe the main components in the project.

## Audio

The audio folder contains the following files:
- "audio_adc" receives 24 bits from the audio CODEC and outputs the MSB as the EAR input on the ULA
- "audio_codec", based on DE2-115 board's System CD demos, generates the clock signals for the audio CODEC in the target platform
- "I2C_AV_Config" and "I2C_Controller", from DE2-115 board's System CD, permit initialization of the audio CODEC

## Joystick

The joystick folder contains the following files:
- "kemptson_if" receives the state of the gamepad and rearanges the data into the kempston interface format
- "nes_gamepad" receives the state data sent by the physical gamepad in series and outputs it in parallel

## Keyboard

A simple diagram of the input receiver module can be seen below:
![leyboard](/img/input-rcvr-basic.svg)

The keyboard folder contains a PS/2 controller by [Jonathan Rose in the University of Toronto](https://www.eecg.utoronto.ca/%7Ejayar/ece241_08F/AudioVideoCores/ps2/ps2.html), used to communicate with the keyboard in both directions. The folder also contains:

- "input_receiver" outputs the keyboard data in the format the ULA expects depending on the address the CPU "selects". 
    - a 5-bit value per half-row is saved and altered depending on the scan codes the PS/2 controller sends.
    - Numlock and Capslock are checked for toggling the keyboard's status LEDs
    - another 2 sets of half-rows are stored for the sinclair controller's state, which is updated depending on the gamepad's received state
    - if the native keyboard is selected, the data bus is connected directly to the ULA keyboard data input
- "keyboard_top" connects the controller and the input_receiver. It is used on the project's "top" to connect it to the rest of the system.

## Z80 CPU

The Z80 implementation used in this project is the [T80](https://opencores.org/projects/t80).

## ULA

The ULA is represented by "ula_top" that connects two different components:
- "ula_count" contains the counters of the original ULA, recreated based on Chris Smith's "The ZX Spectrum ULA" book.
    - It outputs the interrupt signal for the Z80
    - It outputs the Z80's clock, keeping it high when there is memory contention like in the original ZX Spectrums
    - It outputs the flash clock used by the video component to draw flashing attribute blocks
- "ula_port" by [Mike Stirling](https://github.com/mikestir/fpga-spectrum) serves as the peripheral for the Z80:
    - receives EAR out, MIC out and border color from the Z80 when it writes to port 0xFE and outputs them to the audio and video components
    - receives EAR in and keyboard data and outputs them to the Z80 when a read is made on port 0xFE

## Video

A diagram of this component can be seen below:

![video](/img/video-diagram.svg)

The video component's top file is called "video.vhd". It decides the output color (border color or active screen color) and connects the following components:
- "data_interpreter" reads the pixel and color data from the ZX Spectrum's memory depending on the current coordinates being drawn on VGA and outputs the corresponding color
- "vga_controller" by [Scott Larson](https://forum.digikey.com/t/vga-controller-vhdl/12794) which handles the VGA's sync values and keeps track of the X and Y coordinates of the pixel being drawn

The clock required for the 1024x768 @ 60Hz resolution is 65MHz. The pixel data and color data regions are seperated into two dual-port memory modules to allow both to be obtained simultaneously. The clock signal of the memory modules is opposite to the VGA's clock signal to allow for the data to be obtained half a clock before it is drawn.

## <a name="sdcard"></a>SD Card 

SD Card support is implemented by using a NIOS II co-processor, which can be instanced in the Cyclone IV FPGA chip. This co-processor is used as:
- a peripheral for the Z80 to request:
    - the main menu's code by reading port 0x17
    - a page's file list by reading port 0x1B
    - the selected file to be loaded by writing port to 0x1B
- a processor to load files using Direct Memory Access (DMA):
    - writes file data to memory and loads registers by writing assembly code to be executed by the Z80 by enabling a Non-Maskable Interrupt (NMI)
- a processor to save files based on the memory and the Z80 register contents
    - triggered when a push-button is clicked


### Z80 Software
 
The Z80 required a menu to allow the user to request lists of files or files to load. This menu was heavily based on the ZX Spectrum 128k's main menu and reuses some of its assembly code. 

The main code that the ZX Spectrum executes when it starts was altered (specifically at address 0x1295) to jump to a previously unused ROM region (starting at 0x386E) that was changed to contain a condition. This condition determines if NIOS II writes the main menu to the memory of if the ZX Spectrum 48k continues the initialization as normal (in the case of the BASIC option). For this, a flag is kept in address 0xFFFF that determines the state of the main menu. When the ZX Spectrum initializes, it clears all RAM, including this address. However, when the "BASIC" option is selected, a different starting point in the initialization routine is used which doesn't clear all the RAM, leaving behind the state of 0xFFFF. The menu code is written to address 0xB000 and the file list array is stored in address 0xC000.

Data in address 0x0066 correspond to the NMI routine. This was altered to jump to 0x4000, the video memory region. This region was chosen for the NIOS to write register routine manipulating assembly code, required to load or save register values. It was chosen to avoid overwritting important software code, as the file data is loaded to RAM before the Z80's registers. After the routine in address 0x4000 is executed, NIOS writes the original video data present in the region fast enough that the user will not notice.

A memory map of the ZX Fusion canb e seen in the image bellow:

![memory map](/img/fusion-mem-map.svg)

### Structure

The "nios_sd_loader" folder holds all the synthesis files for the NIOS II instance. 

The "Software" folder contains test projects "dma_test" and "ff15_test" used to test DMA with the Z80 and FAT file system access respectively. The folder also contains "memory_manipulator", the main software project. It contains:
- "SD" folder 
    - contains the [FatFs Library](http://elm-chan.org/fsw/ff/) for direct communication with the SD Card 
    - contains "sd_if", an interface to abstract from the basic functions of the library
        - begin a read/write
        - read/write a block of data
        - check if parameter filename has a supported file type
        - get number of SD Card menu pages based on the card's contents
        - get the filenames of a specific page
- "spectrum_control_IFs" which contains:
    - "DMA" folder which contains files pertaining to DMA:
        - "dma_hw" contains the macro definitions for the basic I/O required to request DMA from the Z80, manipulate memory/peripherals of the ZX Spectrum, and enabling the Z80's NMI

        - "dma_hal" abstracts from "dma_hw":
            - request DMA
            - read/write from/to memory or peripherals
            - end DMA with or without NMI enabled

    - "Peripheral_Interfaces" folder which contains files related to the Z80's communication with NIOS as a peripheral
        - "per_hw" contains macro definitions for receiving command data from the Z80
            - Since NIOS and the Z80 run at different clock speeds, a register named "nios_per_reg" exists to save the command data sent by the Z80. This includes the address used in the I/O operation, the data bus if it was a write, and the control bus (read, write, memory request and IO request)
            - The macro definitions get data from this register and also allow it to be reset with a signal named "cpu_cmd_ack"
        - "per_hal" abstracts from "per_hw" with operations pertaining to receiving the data with added context (i.e. "get_if_type" reads the address and returns the interface type)

- "file_reader" which contain functions related to the reading and writing of files from/to the SD Card
    - "asm_opcodes" contains macro definitions for various Z80 assembly opcodes, used to "construct" the register loading/saving routines
    - "mem_addrs" contains macro definitions for the addresses of the register values when these are being saved. They are written to those addresses in memory before being read by NIOS and written to a save state file
    - "file_format_aux" contains auxilary functions related to data conversions (endianness, 8-bit array to a 16-bit value, etc) as well as functions to generate save/load register routines
    - "formats" contain the main functions to execute the loading or saving of files to/from the SD card. It also has auxilary functions to execute the main functions
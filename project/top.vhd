library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
	port (
		CLOCK_50 : IN std_logic;
		------------ VGA -------------
		VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK : out STD_LOGIC;
		VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(7 downto 0);
		
		------------ PS2 -------------
		PS2_CLK, PS2_DAT : inout std_logic;
		
		------------- SD -------------
		SD_CLK      : out std_logic;
		SD_CMD      : inout std_logic;
		SD_DAT      : inout std_logic_vector(3 downto 0);
		SD_WP_N     : in std_logic;
		
		----------- Audio ------------
		AUD_ADCDAT  : in std_logic;
		AUD_DACDAT  : out std_logic;
		AUD_XCK     : out std_logic;
		AUD_BCLK    : out std_logic;
		AUD_DACLRCK : out std_logic;
		AUD_ADCLRCK : out std_logic;
		
		--------- EXPANSION ---------
		KEYB_ADDR   : out std_logic_vector(7 downto 0);
		KEYB_DATA   : in std_logic_vector(4 downto 0);
		
		NES_CLK_1   : out std_logic;
		NES_LATCH_1 : out std_logic;
		NES_DATA_1  : in std_logic;
		
		NES_CLK_2   : out std_logic;
		NES_LATCH_2 : out std_logic;
		NES_DATA_2  : in std_logic;
		
		----------- BOARD ------------
		SW          : in std_logic_vector(17 downto 0);
		KEY         : in std_logic_vector(3 downto 0);
		LEDR        : out std_logic_vector(17 downto 0) := (others => '0');
		LEDG        : out std_logic_vector(7 downto 0) := (others => '0');
		
		LCD_DATA    : out std_logic_vector(7 downto 0) := (others => '0');
		LCD_EN      : out std_logic;
		LCD_RS      : out std_logic;
		LCD_RW      : out std_logic;
		HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0 : out std_logic_vector(0 to 6)
	);
end top;

architecture Behavior of top is
	component double_spin_anim_7seg IS
		PORT ( 
				CLOCK_50       : IN STD_LOGIC;
				SET            : IN STD_LOGIC;
				CLR            : IN STD_LOGIC;
				D3, D2, D1, D0 : OUT STD_LOGIC_VECTOR(0 TO 6)
				);
	END component;

	---------
	-- PLL --
	---------
	component pll IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0'; -- 50 MHz
		c0		: OUT STD_LOGIC ; -- 7 MHz
		c1		: OUT STD_LOGIC ; -- 18 MHz
		c2		: OUT STD_LOGIC ; -- 65 MHz
		c3		: OUT STD_LOGIC ; -- 22,5 MHz
		locked		: OUT STD_LOGIC 
	);
	END component;
	
	-------------------
	-- RESET COUNTER --
	-------------------
	component reset_counter IS
		PORT
		(
			aclr		: IN STD_LOGIC ;
			clk_en		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END component;
	
	---------
	-- CPU --
	---------
	component T80a is
		port(
			RESET_n         : in std_logic;
			CLK_n           : in std_logic;
			WAIT_n          : in std_logic;
			INT_n           : in std_logic;
			NMI_n           : in std_logic;
			BUSRQ_n         : in std_logic;
			M1_n            : out std_logic;
			MREQ_n          : out std_logic;
			IORQ_n          : out std_logic;
			RD_n            : out std_logic;
			WR_n            : out std_logic;
			RFSH_n          : out std_logic;
			HALT_n          : out std_logic;
			BUSAK_n         : out std_logic;
			A                       : out std_logic_vector(15 downto 0);
			D                       : inout std_logic_vector(7 downto 0);
			INT_INF         : out std_logic_vector(3 downto 0));
			
			--DEBUG_PC	: out std_logic_vector(15 downto 0));
	end component;
	
	---------
	-- RAM --
	---------
	
	-- Address 0x0000 - 0x3FFF
	component rom IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (13 DOWNTO 0);
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rden		: IN STD_LOGIC  := '1';
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;
	
	-- Address 0x4000 - 0x57FF
	component pixel_video_ram IS
		PORT
		(
			-- a -> accessed by video
			-- b -> accessed by CPU
			address_a		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
			address_b		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
			clock_a		: IN STD_LOGIC  := '1';
			clock_b		: IN STD_LOGIC ;
			data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			enable_a		: IN STD_LOGIC  := '1';
			enable_b		: IN STD_LOGIC  := '1';
			wren_a		: IN STD_LOGIC  := '0';
			wren_b		: IN STD_LOGIC  := '0';
			q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;
	
	-- Address 0x5800 - 0x5AFF
	component color_video_ram IS
	PORT
	(
		-- a -> accessed by video
		-- b -> accessed by CPU
		address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock_a		: IN STD_LOGIC  := '1';
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		enable_a		: IN STD_LOGIC  := '1';
		enable_b		: IN STD_LOGIC  := '1';
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component;

	-- Address 0x5B00 - 0xFFFF
	component remaining_ram IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rden		: IN STD_LOGIC  := '1';
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;
	
	-----------
	-- Video --
	-----------
	component video is
		port(
			CLOCK, FLASH_CLK, RESET : IN std_logic; -- 65MHz video clock
			MODE : in std_logic_vector(1 downto 0);
			PIXEL_DATA, COLOR_DATA	: IN std_logic_vector(7 downto 0);
			BORDER : in std_logic_vector(2 downto 0);
			PIXEL_RE, COLOR_RE : out std_logic;
			PIXEL_ADDR : OUT std_logic_vector(12 downto 0);
			COLOR_ADDR : out std_logic_vector(9 downto 0);
			VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N : out STD_LOGIC;
			VGA_CLK : OUT std_logic; -- 65MHz reverse phase
			VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(7 downto 0));
	end component;
	
	---------
	-- ULA --
	---------
	
	component ula_top is
		port (
			CLK			: in std_logic;
			nRESET		: in std_logic;
			
			-- PORT --
			D_IN			:	in	std_logic_vector(7 downto 0);
			D_OUT			:	out std_logic_vector(7 downto 0);
			ENABLE		:	in	std_logic;
			WR_e			:	in	std_logic;
			
			BORDER_OUT	:	out std_logic_vector(2 downto 0);
			EAR_OUT		:	out std_logic;
			MIC_OUT		:	out std_logic;
			
			KEYB_IN		:	in std_logic_vector(4 downto 0);
			EAR_IN		:	in	std_logic;
			
			-- COUNT --
			nTCLKA		: in std_logic; -- Upper Counter Stage Test Clock = nIOREQ and nMREQ and nRD and !nWR
			nTCLKB		: in std_logic; -- Flash Counter Test Clock = nIOREQ and nMREQ and !nRD and nWR
			
			MREQ_n		: in std_logic;
			IOREQ_n		: in std_logic;

			TOP_ADDRESS	: in	std_logic_vector(1 downto 0);
			
			nINT			: out	std_logic; -- Interrupt
			CPU_CLK		: out	std_logic; -- 3.5MHz
			FLASH_CLK	: out std_logic -- 1.56 Hz
			--IOREQGTW3_n	: out std_logic
		);
	end component;
	
	
	-----------
	-- Audio --
	-----------
	component audio_codec is
		port (
			CLK		:	in	std_logic;
			nRESET	:	in	std_logic;
			
			AUD_BCLK	:	out std_logic;
			AUD_LRCLK	:	out std_logic
		);
	end component;
	
	component audio_adc is
		port (
			CLK			:	in	std_logic;
			nRESET		:	in	std_logic;
			ADC_DAT		:	in std_logic;
			
			EAR		:	out std_logic
		);
	end component;
	--------------
	-- Joystick --
	--------------
	component nes_gamepad is
    Port ( 
           clk       : in STD_LOGIC;
           nes_data_1  : in STD_LOGIC;
			  nes_data_2  : in STD_LOGIC;
           nes_latch : out STD_LOGIC := '0';
           nes_clk   : out STD_LOGIC := '0';
           state_1 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
			  state_2 : out STD_LOGIC_VECTOR (7 downto 0) := (others => '0')
    );
	end component;
	
	-- Kempston --
	component kempston_if is
		port(
			EN, RESET : in std_logic;
			JOY_STATE : in std_logic_vector(7 downto 0);
			DATA : out std_logic_vector(7 downto 0) := (others => '1')
		);
	end component;
	
	--------------
	-- Keyboard --
	--------------
	component keyboard_top is
		port(
			CLOCK, RESET : in std_logic;
			PS2_CLOCK, PS2_DATA : inout std_logic;
			NATIVE_DATA : in std_logic_vector(4 downto 0);
			NATnPS2 : in std_logic;
			ADDRESS : in std_logic_vector(7 downto 0);
			JOY1_STATE : in std_logic_vector(7 downto 0);
			JOY2_STATE : in std_logic_vector(7 downto 0);
			KEY_DATA : out std_logic_vector(4 downto 0)
		);
	end component;

	----------
	-- NIOS --
	----------
	component nios_sd_loader is
		port (
			address_external_connection_export     : out   std_logic_vector(15 downto 0);                    --  address for DMA
			bus_ack_n_external_connection_export   : in    std_logic                     := '0';             --  bus ack from T80
			bus_req_n_external_connection_export   : out   std_logic;                                        --  bus req for T80
			clk_clk                                : in    std_logic                     := '0';             --  clock
			
			cpu_address_direct_external_connection_export : in    std_logic_vector(15 downto 0) := (others => '0'); -- address of CPU, not passing through regs, to check when PC is accessed after loading a game
			cpu_address_external_connection_export : in    std_logic_vector(15 downto 0) := (others => '0'); --  address of CPU, for interface and page num
			cpu_cmd_ack_external_connection_export : out   std_logic;                                        --  acknowledge, for clearing buffers			
			cpu_cmd_en_external_connection_export  : in    std_logic                     := '0';             --  enable nios for cpu to send commands to
			cpu_cmd_external_connection_export     : in    std_logic_vector(7 downto 0)  := (others => '0'); --  cpu data line, used for commands
			cpu_int_inf_external_connection_export : in    std_logic_vector(3 downto 0)  := (others => '0'); -- IFF2, IFF1, IM
			cpu_rd_n_external_connection_export    : in    std_logic                     := '0';             --  read enable from T80
			cpu_wr_n_external_connection_export    : in    std_logic                     := '0';             --  write enable from T80
			
			ctrl_bus_external_connection_export    : out   std_logic_vector(3 downto 0);                     --  3:RD, 2:WR, 1:MEMRQ, 0:IORQ
			data_external_connection_export        : inout std_logic_vector(7 downto 0)  := (others => '0'); --  data bus for DMA
			ledg_pio_external_connection_export    : out   std_logic_vector(7 downto 0);                     --  test LEDs
			nmi_n_external_connection_export       : out   std_logic;                                        --  non maskable interrupt
			reset_reset_n                          : in    std_logic                     := '0';             --  reset
			
			-- LCD External
			lcd_external_data  : out   std_logic_vector(7 downto 0);                                         -- LCD Data
			lcd_external_E     : out   std_logic;                                                            -- LCD enable
			lcd_external_RS    : out   std_logic;                                 -- LCD Command/Data select (cmd = 0)
			lcd_external_RW    : out   std_logic;                                 -- LCD Read/Write (write = 0)
			
			
			sd_clk_external_connection_export      : out   std_logic;                                        --  sd_clk
			sd_cs_external_connection_export       : out   std_logic;                                        --  sd SPI Chip Select
			sd_miso_external_connection_export     : in    std_logic                     := '0';             --  sd SPI Data Out
			sd_mosi_external_connection_export     : out   std_logic;                                        --  sd SPI Data In
			sd_wp_n_external_connection_export     : in    std_logic                     := '0'              --  sd_wp_n
		);
	end component;
	
	
	component nios_per_reg IS 
		PORT 
		( 
			clk						: in std_logic;

			address_in				: in std_logic_vector(15 downto 0);
			data_in					: in std_logic_vector(7 downto 0);
			rd_n_in, wr_n_in		: in std_logic;
			
			address_out				: out std_logic_vector(15 downto 0) := (others => '0');
			data_out					: out std_logic_vector(7 downto 0) := (others => '0');
			rd_n_out, wr_n_out	: out std_logic := '1';
			en_out					: out std_logic := '0';
			
			reset, oe				: in std_logic
		); 
	END component;
	
	-------------
	-- SIGNALS --
	-------------
	
	-- PLL --
	signal pll_reset : std_logic := '0';															-- IN
	signal ula_clock, video_clock, pll_locked : std_logic;									-- OUT
	signal audio_ctrl_clk : std_logic := '0';
	
	-- CPU --
	signal cpu_reset_n : std_logic := '1';
	signal cpu_wait_n : std_logic := '1';
	signal cpu_nmi_n : std_logic := '1';
	signal cpu_busrq_n : std_logic := '1';
	
	signal cpu_clock : std_logic := '0';
	signal cpu_nmi : std_logic := '0';
	
	signal cpu_int_n : std_logic := '1';
	signal cpu_m1_n : std_logic := '1';
	signal cpu_mreq_n : std_logic := '1';
	signal cpu_iorq_n : std_logic := '1';
	signal cpu_rd_n : std_logic := '1';
	signal cpu_wr_n : std_logic := '1';
	signal cpu_rfsh_n : std_logic := '1';
	signal cpu_halt_n : std_logic := '1';
	signal cpu_busak_n : std_logic := '1';
	
	signal cpu_address : std_logic_vector(15 downto 0) := x"0000";
	signal cpu_data: std_logic_vector(7 downto 0) := X"00";
	signal cpu_data_in : std_logic_vector(7 downto 0) := X"00";
	signal cpu_data_out : std_logic_vector(7 downto 0) := X"00";
	
	-- Internal CPU --
	signal cpu_int_inf : std_logic_vector(3 downto 0) := "0000";
	--signal iff2, iff1 : std_logic := '0';                                -- Interrupt flip-flops
	--signal im : std_logic_vector(1 downto 0) := "00";                    -- Interrupt Mode
	
	-- NIOS --
	signal nios_en, nios_reset_n : std_logic;
	signal nios_ctrl_bus : std_logic_vector(3 downto 0);
	signal nios_rd_n, nios_wr_n, nios_mreq_n, nios_iorq_n : std_logic;
	signal nios_data, nios_data_in, nios_data_out : std_logic_vector(7 downto 0);
	signal nios_address : std_logic_vector(15 downto 0);
	signal nios_clock : std_logic := '0';
	
	signal nios_reg_en : std_logic := '0';
	
	signal nios_reg_addr_in : std_logic_vector(15 downto 0) := x"0000";
	signal nios_reg_data_in : std_logic_vector(7 downto 0) := x"00";
	signal nios_reg_rd_n_in : std_logic := '1';
	signal nios_reg_wr_n_in : std_logic := '1';
	
	signal cpu_address_reg_out : std_logic_vector(15 downto 0) := x"0000";
	signal cpu_cmd_reg_out : std_logic_vector(7 downto 0) := x"00";
	signal cpu_rd_n_reg_out : std_logic := '1';
	signal cpu_wr_n_reg_out : std_logic := '1';
	signal cpu_cmd_ack : std_logic := '0';
	signal nios_en_reg_out : std_logic := '0';
	
	signal nios_reg_reset : std_logic := '0';
	
	-- SPI SD --
	signal sd_cs : std_logic := '1';
	signal sd_do : std_logic := '0';
	signal sd_di : std_logic := '0';
	
	-- CPU Shared signals --
	signal read_en, write_en, mreq_n, iorq_n : std_logic;
	signal data_in, data_out : std_logic_vector(7 downto 0);
	signal address : std_logic_vector(15 downto 0);
	
	-- ROM --
	signal rom_address : std_logic_vector(13 downto 0);
	signal rom_en : std_logic;
	signal rom_data_in : std_logic_vector(7 downto 0) := (others => '0'); -- Is this necessary?
	signal rom_data_out : std_logic_vector(7 downto 0);
	
	-- Pixel RAM --
	signal video_pixel_addr, cpu_pixel_addr : std_logic_vector(12 downto 0);
	signal cpu_pixel_addr_num : std_logic_vector(15 downto 0);
	signal cpu_pixel_data_out, video_pixel_data_out : std_logic_vector(7 downto 0);
	signal cpu_pixel_en, video_pixel_read : std_logic;
	
	-- Color RAM --
	signal video_color_addr, cpu_color_addr : std_logic_vector(9 downto 0);
	signal cpu_color_addr_num : std_logic_vector(15 downto 0);
	signal cpu_color_data_out, video_color_data_out : std_logic_vector(7 downto 0);
	signal ula_read_bus : std_logic_vector(7 downto 0); -- for floating bus behaviour recreation
	signal cpu_color_en, video_color_read : std_logic;
	
	-- Remaining RAM --
	signal ram_address : std_logic_vector(15 downto 0);
	signal ram_en : std_logic;
	signal ram_data_out : std_logic_vector(7 downto 0);
	
	-- Video --
	signal video_reset : std_logic;
	signal video_mode : std_logic_vector(1 downto 0);
	
	-- ULA --
	signal ula_reset_n : std_logic := '1';
	signal ula_data_out : std_logic_vector(7 downto 0);
	signal ula_border_out : std_logic_vector(2 downto 0);
	signal ula_en, ula_speaker_out, ula_mic_out, ula_ear_in : std_logic;
	signal flash_clk : std_logic;
	signal ula_a : std_logic_vector(1 downto 0);
	signal ula_in_iorq_n : std_logic := '1';
	--signal delayed_iorq_n : std_logic := '1'; -- IOREQTW3
	
	-- Audio --
	signal audio_stream_clk : std_logic := '0';
	signal audio_lr_clk : std_logic := '0';
	signal audio_codec_in : std_logic := '0';
	signal audio_codec_out : std_logic := '0';
	
	-- Joystick --
	signal joy_data_1 : std_logic := '1';
	signal joy_data_2 : std_logic := '1';
	
	signal joy_latch : std_logic := '0';

	signal joy_clk : std_logic := '0';

	signal joy_state_1 : std_logic_vector(7 downto 0) := (others => '0');
	signal joy_state_2 : std_logic_vector(7 downto 0) := (others => '0');
	
	signal kemp_n_sin : std_logic := '0';
	
	-- Kempston --
	signal kemp_joy_1 : std_logic_vector(7 downto 0) := (others => '0');
	signal kemp_data_out : std_logic_vector(7 downto 0) := (others => '1');
	signal kemp_en : std_logic := '0';
	
	-- Keyboard --
	signal keyboard_data_out : std_logic_vector(4 downto 0);
	signal keyboard_reset : std_logic;
	signal keyboard_native_data : std_logic_vector(4 downto 0) := (others => '1'); -- CHANGE LATER?
	signal native_n_ps2 : std_logic;
	signal keyb_joy1 : std_logic_vector(7 downto 0) := (others => '0');
	signal keyb_joy2 : std_logic_vector(7 downto 0) := (others => '0');

	-- TEST signals
	signal ula_tclka_n, ula_tclkb_n : std_logic;
	
	-- Reset Counter --
	signal rst_ctr_num : std_logic_vector(9 downto 0);
	signal ctr_en : std_logic;
	
	-- Global --
	signal global_reset : std_logic;
	signal save_state : std_logic;
	
	signal ula_c, ula_v : std_logic_vector(8 downto 0);
	
	signal nmi_ff_reset, nmi_ff_set : std_logic := '0';
	signal nios_nmi_n_out : std_logic := '1';
begin
	
	------------
	-- INPUTS --
	------------
	global_reset <= not KEY(0);
	save_state <= not KEY(3);
	kemp_n_sin <= SW(17);
	native_n_ps2 <= SW(16);
	
	-- "00" 4x/"01" 4x w border/"10" 2x/"11" 1x
	video_mode <= SW(1 downto 0); 
--	global_reset <= SW(0);
--	LEDR(15 downto 0) <= cpu_address;
--	LEDR(9 downto 0) <= rst_ctr_num;
--	LEDR(10) <= rst_ctr_cy;
--	LEDG(6) <= ula_clock;
--	LEDG(5) <= video_clock;
--	LEDG(4) <= pll_locked;
--	LEDG(0) <= cpu_clock;

	LEDR(17) <= nios_en_reg_out;
	LEDR(16) <= save_state;
--	LEDR(16) <= not cpu_halt_n;
--	LEDR(15) <= ula_speaker_out;
--	LEDR(7 downto 0) <= ula_data_out;
--	LEDR(16) <= cpu_rd_n_reg_out;
--	LEDR(15) <= cpu_wr_n_reg_out;
--	LEDR(14) <= cpu_cmd_ack;
--	LEDR(13 downto 0) <= cpu_address_reg_out(13 downto 0);

	-- When testing NIOS connection --
--	LEDR(0) <= not cpu_busrq_n;
--	LEDR(1) <= not cpu_busak_n;
--	LEDR(2) <= read_en;
--	LEDR(3) <= write_en;
--	LEDR(4) <= not mreq_n;
--	LEDR(5) <= not iorq_n;
--	LEDR(6) <= not cpu_iorq_n;
	
	--LEDR(8) <= video_reset;
	
--	LEDR(17 downto 10) <= nios_data;


	double_spin : double_spin_anim_7seg port map (
			CLOCK_50 => CLOCK_50,
			SET      => not nios_en_reg_out,
			CLR      => SW(2),
			D3       => HEX7, 
			D2       => HEX6, 
			D1       => HEX5, 
			D0       => HEX4
		);
	HEX3 <= (others => '1');
	HEX2 <= (others => '1');
	HEX1 <= (others => '1');
	HEX0 <= (others => '1');
	---------
	-- PLL --
	---------
	main_pll : pll port map (
			areset	=> pll_reset,
			inclk0	=> CLOCK_50,
			c0			=> ula_clock,	      -- 7 MHz
			c1			=> audio_ctrl_clk,	-- 18 MHz
			c2			=> video_clock,		-- 65 MHz
			c3			=> nios_clock,
			locked	=> pll_locked
		);
		
	---------
	-- CPU --
	---------
	z80 : T80a port map (
			RESET_n	=> cpu_reset_n,
			CLK_n		=> not cpu_clock,
			WAIT_n	=> cpu_wait_n,
			INT_n		=> cpu_int_n,			-- Interrupt
			NMI_n		=> cpu_nmi_n,			-- Non-Maskable Interrupt
			BUSRQ_n	=> cpu_busrq_n,		-- Bus Request
			M1_n		=> cpu_m1_n,			-- M1
			MREQ_n	=> cpu_mreq_n,			-- Memory Request
			IORQ_n	=> cpu_iorq_n,			-- IO Request
			RD_n		=> cpu_rd_n,			-- Read
			WR_n		=> cpu_wr_n,			-- Write
			RFSH_n	=> cpu_rfsh_n,			-- Memory Refresh
			HALT_n	=> cpu_halt_n,			-- Halt
			BUSAK_n	=> cpu_busak_n,		-- Bus Acknowledge
			A			=> cpu_address,		-- Address
			D			=> cpu_data,			-- Data
			INT_INF	=> cpu_int_inf		-- IFF2, IFF1, IM
		);
	--iff2 <= cpu_int_inf(3);
	--iff1 <= cpu_int_inf(2);
	--im <= cpu_int_inf(1 downto 0);
		
	----------
	-- NIOS --
	----------
	SD_DAT(3) <= sd_cs;
	sd_do <= SD_DAT(0);
	SD_CMD <= sd_di;
	
	
	nmi_ff_reset <= not cpu_m1_n;
	nmi_ff_set <= not nios_nmi_n_out;
	
	process(nmi_ff_reset, nmi_ff_set)
	begin
		--if (rising_edge(CLOCK_50)) then
			if (nmi_ff_reset = '1' and nmi_ff_set = '0') then
				cpu_nmi_n <= '1';
			elsif (nmi_ff_reset = '0' and nmi_ff_set = '1') then
				cpu_nmi_n <= '0';
--			elsif (nmi_ff_reset = '0' and nmi_ff_set = '0') then
--				cpu_nmi_n <= '1';
--			elsif (nmi_ff_reset = '1' and nmi_ff_set = '1') then
--				cpu_nmi_n <= '1';
			end if;
		--end if;
	end process;
	
	sd_loader : nios_sd_loader port map(
			clk_clk											=> nios_clock,
			reset_reset_n									=> nios_reset_n,
			ledg_pio_external_connection_export		=> LEDG,
			
			-- SD --
			sd_clk_external_connection_export		=> SD_CLK,
			sd_cs_external_connection_export			=> sd_cs,
			sd_miso_external_connection_export		=> sd_do,
			sd_mosi_external_connection_export		=> sd_di,
			sd_wp_n_external_connection_export		=> SD_WP_N,
		
			-- CPU to NIOS --
			cpu_cmd_ack_external_connection_export => cpu_cmd_ack,
			cpu_address_external_connection_export => cpu_address_reg_out,
			cpu_cmd_en_external_connection_export	=> nios_en_reg_out,
			cpu_cmd_external_connection_export		=> cpu_cmd_reg_out,
			cpu_int_inf_external_connection_export => cpu_int_inf,
			cpu_rd_n_external_connection_export		=> cpu_rd_n_reg_out,
			cpu_wr_n_external_connection_export		=> cpu_wr_n_reg_out,
		
			-- NIOS to CPU --
			bus_req_n_external_connection_export	=> cpu_busrq_n,
			bus_ack_n_external_connection_export	=> cpu_busak_n,
			nmi_n_external_connection_export			=> nios_nmi_n_out,
			cpu_address_direct_external_connection_export => address,
			
			-- NIOS with DMA --
			ctrl_bus_external_connection_export		=> nios_ctrl_bus,
			address_external_connection_export		=> nios_address,
			data_external_connection_export			=> nios_data,
			
			-- LCD --
			lcd_external_data  => LCD_DATA,
			lcd_external_E     => LCD_EN,
			lcd_external_RS    => LCD_RS,
			lcd_external_RW    => LCD_RW
			
		);
			
			
	-- This register was originally only for CPU commands to be saved for NIOS to read the command when ready
	-- Now, since save states are triggered away from the CPU, this was adapted to receive hardcoded values for a save state command
	
	-- Resetting the register after the command saved in it is processed by NIOS (it sends cpu_cmd_ack), 
	-- or when the rest of the system is reset. 
	nios_reg_reset <= cpu_cmd_ack or (not nios_reset_n);
	
	nios_reg_en <= (nios_en AND (cpu_rd_n XOR cpu_wr_n)) or save_state; 
	
	nios_reg_addr_in <= cpu_address when save_state = '0' else x"0019";	-- 0x19 for save state
	nios_reg_data_in <= cpu_data_out; 												-- unnecessary for save state
	nios_reg_rd_n_in <= cpu_rd_n when save_state = '0' else '1';
	nios_reg_wr_n_in <= cpu_wr_n when save_state = '0' else '0';			-- forcing a write for save state command

	nios_reg : nios_per_reg port map (
			clk			=> ula_clock,
			address_in	=> nios_reg_addr_in,
			data_in		=> nios_reg_data_in,
			rd_n_in		=> nios_reg_rd_n_in,
			wr_n_in		=> nios_reg_wr_n_in,
			
			address_out => cpu_address_reg_out,
			data_out		=> cpu_cmd_reg_out,
			rd_n_out		=> cpu_rd_n_reg_out,
			wr_n_out		=> cpu_wr_n_reg_out,
			en_out		=> nios_en_reg_out,
			
			oe				=> nios_reg_en,
			reset			=> nios_reg_reset
		);
		
	---------
	-- ROM --
	---------
	rom_mem : rom port map (
			address	=> rom_address,
			clken		=> rom_en,				-- ENABLE
			clock		=> CLOCK_50,			-- SHOULD THIS BE THE CLOCK?
			data		=> rom_data_in,		-- Always 0?
			rden		=> read_en,				-- CPU read
			wren		=> write_en,				-- CPU write (Always 0?)
			q			=> rom_data_out		-- Data out
		);
		
	----------------
	-- PIXEL RAM --
	----------------
	pixel_memory : pixel_video_ram port map(
			-- VIDEO --								-- CPU --
			address_a 	=> video_pixel_addr, 	address_b 	=> cpu_pixel_addr,
			clock_a 		=> video_clock, 			clock_b 		=> CLOCK_50,		-- SHOULD THESE BE THE CLOCKS?
			data_a 		=> (others => '0'), 		data_b 		=> data_out,
			enable_a 	=> video_pixel_read, 	enable_b 	=> cpu_pixel_en,
			wren_a 		=> '0',						wren_b		=> write_en,
			q_a			=> video_pixel_data_out, q_b			=> cpu_pixel_data_out
		);
		
	---------------
	-- COLOR RAM --
	---------------
	color_memory : color_video_ram port map(
			-- VIDEO --									-- CPU --
			address_a	=> video_color_addr,		address_b => cpu_color_addr,
			clock_a 		=> video_clock, 			clock_b 		=> CLOCK_50,		-- SHOULD THESE BE THE CLOCKS?
			data_a 		=> (others => '0'), 		data_b 		=> data_out,
			enable_a		=> video_color_read,		enable_b		=> cpu_color_en,
			wren_a 		=> '0',						wren_b		=> write_en,
			q_a			=> video_color_data_out,q_b			=> cpu_color_data_out
		);
		
	-- Combining both memory data busses into one, for floating bus behaviour recreation
	ula_read_bus <= 	video_pixel_data_out when video_pixel_read = '0' else 
							video_color_data_out when video_color_read = '0' else
							"ZZZZZZZZ";
		
	-------------------
	-- REMAINING RAM --
	-------------------
	ram : remaining_ram port map(
			address	=> ram_address,
			clken		=> ram_en,				-- ENABLE
			clock		=> CLOCK_50,			-- SHOULD THIS BE THE CLOCK?
			data		=> data_out,			-- Data in
			rden		=> read_en,				-- read
			wren		=> write_en,			-- write
			q			=> ram_data_out		-- Data out
		);
		
	-----------
	-- VIDEO --
	-----------
	video_processor : video port map(
			CLOCK 		=> video_clock,
			FLASH_CLK	=> flash_clk,
			RESET 		=> video_reset,
			MODE			=> video_mode,
			-- Memory Data --
			PIXEL_DATA	=> video_pixel_data_out,
			COLOR_DATA	=> video_color_data_out,
			-- Border --
			BORDER => ula_border_out,
			-- Memory Enables --
			PIXEL_RE		=> video_pixel_read,
			COLOR_RE		=> video_color_read,
			-- Memory Addresses --
			PIXEL_ADDR	=> video_pixel_addr,
			COLOR_ADDR	=> video_color_addr,
			-- VGA Signals --
			VGA_HS		=> VGA_HS,
			VGA_VS		=> VGA_VS,
			VGA_BLANK_N	=> VGA_BLANK_N,
			VGA_SYNC_N	=> VGA_SYNC_N,
			VGA_CLK		=> VGA_CLK,
			VGA_R			=> VGA_R,
			VGA_G			=> VGA_G,
			VGA_B			=> VGA_B
		);
		
	---------
	-- ULA --
	---------
	ula : ula_top port map(
			CLK			=> ula_clock,
			nRESET		=> ula_reset_n,
			
			-- PORTS --
			D_IN			=> data_out,
			D_OUT			=> ula_data_out,
			ENABLE		=> ula_en,
			WR_e			=> write_en,
			
			BORDER_OUT	=> ula_border_out,
			EAR_OUT		=> ula_speaker_out,
			MIC_OUT		=> ula_mic_out,
			
			KEYB_IN		=> keyboard_data_out,
			EAR_IN		=> ula_ear_in,
			
			-- COUNT --
			nTCLKA		=> ula_tclka_n,
			nTCLKB		=> ula_tclkb_n,
			
			MREQ_n		=> mreq_n,
			IOREQ_n		=> ula_in_iorq_n,
			TOP_ADDRESS	=> ula_a,
			
			nINT			=> cpu_int_n,
			CPU_CLK		=> cpu_clock,
			FLASH_CLK	=> flash_clk
			--IOREQGTW3_n => delayed_iorq_n
	);
	
	ula_in_iorq_n <= iorq_n OR address(0); -- for proper i/o contention handling (spider modification)
	ula_a <= address(15) & address(14);
	
	-----------
	-- Audio --
	-----------
	AUD_XCK <= audio_ctrl_clk;
	AUD_BCLK <= audio_stream_clk;
	AUD_DACLRCK <= audio_lr_clk;
	AUD_ADCLRCK <= audio_lr_clk;
	audio_codec_in <= AUD_ADCDAT;
	AUD_DACDAT <= audio_codec_out;
	
	audio_codec_out <= ula_speaker_out xor ula_mic_out; -- dunno what to do with ula_mic_out, but should be here somehow

	audio : audio_codec port map(
		CLK			=> audio_ctrl_clk,
		nRESET		=> ula_reset_n,
		
		AUD_BCLK		=> audio_stream_clk,
		AUD_LRCLK 	=> audio_lr_clk
	);
	
	audioADC: audio_adc port map(
		CLK		=> audio_ctrl_clk,
		nRESET	=> ula_reset_n,
		ADC_DAT	=> audio_codec_in,
		
		EAR		=> ula_ear_in
	);
	
	--------------
	-- Joystick --
	--------------
	NES_CLK_1 <= joy_clk;
	NES_LATCH_1 <= joy_latch;
	joy_data_1 <= NES_DATA_1;
	joys : nes_gamepad port map (
			clk 			=> CLOCK_50,
			nes_data_1	=> joy_data_1,
			nes_data_2	=> joy_data_2,
			nes_latch	=> joy_latch,
			nes_clk		=> joy_clk,
			state_1		=> joy_state_1,
			state_2		=> joy_state_2
	);
	
	NES_CLK_2 <= joy_clk;
	NES_LATCH_2 <= joy_latch;
	joy_data_2 <= NES_DATA_2;
	
	-- Kempston --
	kempston_interface : kempston_if port map(
			EN				=> kemp_en,
			RESET			=> keyboard_reset,
			JOY_STATE	=> kemp_joy_1,
			DATA			=> kemp_data_out
	);
	
	--------------
	-- Keyboard --
	--------------
	KEYB_ADDR <= address(15 downto 8);
	keyboard_native_data <= KEYB_DATA;
	keyboard : keyboard_top port map(
			CLOCK			=>	CLOCK_50,
			RESET			=> keyboard_reset,
			PS2_CLOCK	=> PS2_CLK,
			PS2_DATA		=> PS2_DAT,
			NATIVE_DATA => keyboard_native_data,
			NATnPS2		=> native_n_ps2,
			ADDRESS		=> address(15 downto 8),
			JOY1_STATE	=> keyb_joy1,
			JOY2_STATE	=> keyb_joy2,
			KEY_DATA		=> keyboard_data_out
		);
	
	-------------------
	-- RESET COUNTER --
	-------------------
	ctr_en <= not rst_ctr_num(9);
	reseter : reset_counter port map(
			aclr			=> global_reset,
			clk_en			=> ctr_en,
			clock			=> CLOCK_50,
  			q				=> rst_ctr_num
		);
		
		
	-- Restart order matters:
	-- PLL first, since it gives off the clocks
	-- CPU last (at least not during ULA reset, since this gives the CPU its clocks)
	
	pll_reset <= '1' when rst_ctr_num(9 downto 3)= "0000001" else '0';
	
	video_reset <= '1' when rst_ctr_num(9 downto 5) = "00001" else '0';
	keyboard_reset <= '1' when rst_ctr_num(9 downto 5) = "00001" else '0';
	nios_reset_n <= '0' when rst_ctr_num(9 downto 5) = "00001" else '1';
	ula_reset_n <= '0' when rst_ctr_num(9 downto 5) = "00001" else '1';
	
	cpu_reset_n <= '0' when rst_ctr_num(9 downto 7) = "001" else '1';

	--------------------------------------------------------------------
	
	----------------------------
	-- Joystick Interface MUX --
	----------------------------
	keyb_joy2 <= joy_state_2;
	
	-- HERE TEST IF WORKS --
	-- TODO
	keyb_joy1 <= joy_state_1 when kemp_n_sin = '0' else (others => '0');
	kemp_joy_1 <= (others => '0') when kemp_n_sin = '0' else joy_state_1;
	
--	process(kemp_n_sin, joy_state_1)
--	begin
--		if (kemp_n_sin = '0') then
--			keyb_joy1 <= joy_state_1;
--			kemp_joy_1 <= (others => '0');
--		else
--			kemp_joy_1 <= joy_state_1;
--			keyb_joy1 <= (others => '0');
--		end if;
--	end process;

	
	
	---------------------
	-- NIOS BUS DECOMP --
	---------------------
	nios_rd_n <= nios_ctrl_bus(3);
	nios_wr_n <= nios_ctrl_bus(2);
	nios_mreq_n <= nios_ctrl_bus(1);
	nios_iorq_n <= nios_ctrl_bus(0);
	
	
	-------------------------
	-- Access calculations --
	-------------------------
	
	-- IO --
	
	-- Enable for T80 communication with NIOS. Does not influence when DMA is happening
	nios_en <= '1' when iorq_n = '0' and cpu_mreq_n = '1' and ( --cpu_iorq_n = '0' and cpu_mreq_n = '1' and (
								address(7 downto 0) = x"17" or
								address(7 downto 0) = x"19" or
								address(7 downto 0) = x"1B" or
								address(7 downto 0) = x"1D") and --and (address(4) = '1' and address(0) = '1') and 
					cpu_busak_n = '1' else 	-- making sure the enable only happens when the T80 is in charge
					'0';
	
	-- Technically all even number IO work for the ULA, but only FE is really used
	ula_en <= '1' when iorq_n = '0' and mreq_n = '1' and address(7 downto 0) = X"FE" else 
					'0';

	-- Kempston interface at address 0x1F
	kemp_en <= '1' when iorq_n = '0' and mreq_n = '1' and address(7 downto 0) = x"1F" else
					'0';
	
	-- MEMORY --
	
	-- '1' when in the range 0x0000 to 0x3FFF
	rom_en <= not (mreq_n or cpu_rd_n or address(15) or address(14));--(not mreq_n) and (not cpu_rd_n)
	
--	'0' when mreq_n = '1' or iorq_n = '0' or cpu_rd_n = '1' or cpu_wr_n = '0' else
--					'1' when address(15 downto 14) = "00";
	
	-- '1' when in the range 0x4000 to 0x4fff OR in the range 0x5000 to 0x57FF
	cpu_pixel_en <= not (mreq_n or 
							address(15) or (not address(14)) or address(13) or ( -- limits address to 0x4000 to 0x5FFF
									not (not address(12) or not address(11)) -- limits address to not exceed 0x57FF
								));
--	
--	'0' when mreq_n = '1' or iorq_n = '0' else
--							'1' when ((address(15 downto 12) = "0100") or (address(15 downto 11) = "01010"));

	-- '1' when in the range 0x5800 to 0x5AFF
	cpu_color_en <= not (mreq_n or 
								address(15) or (not address(14)) or address(13) or (not address(12)) or (not address(11)) or address(10) or ( -- limit address to 0x5800 to 0x5BFF
										not (not address(9) or not address(8)) -- A9 and A8 can't be both 1, limiting address to 0x5AFF instead of 0x5BFF
									));
	
--	'0' when mreq_n = '1' or iorq_n = '0' else
--							'1' when ((address(15 downto 10) = "010110") and not (address(9) = '1' and address(8) = '1'));
	
	-- '1' when mem_req is on but no other memory is being accessed
	ram_en <= (not mreq_n) and (
						address(15) or (address(14) and ( -- 01000000... to 11111111... (0x4000 to 0xFFFF)
							address(13) OR ( -- 01100000... to 11111111... (0x6000 to 0xFFFF)
								(address(12) and address(11)) AND -- 01011000... to 11111111... (0x5800 to 0xFFFF)
								(address(10) or (address(9) and address(8))) -- 01011011... to 11111111... (0x5B00 to 0xFFFF)
							)
						))
					);
	
	----------------------
	-- Memory Addresses --
	----------------------
	cpu_pixel_addr_num <= (address - x"4000");
	cpu_color_addr_num <= (address - x"5800");
	
	rom_address <= address(13 downto 0) when rom_en = '1' 
											else (others => '0');
	cpu_pixel_addr <= cpu_pixel_addr_num(12 downto 0) when cpu_pixel_en = '1'
											else (others => '0');
											
	cpu_color_addr <= cpu_color_addr_num(9 downto 0) when cpu_color_en = '1'
											else (others => '0');
											
	ram_address <= (address-x"5B00") when ram_en = '1'
											else (others => '0');
	
	-- CPU data buffer --
	cpu_data <= "ZZZZZZZZ" when cpu_rd_n = '1' and cpu_wr_n = '0' else cpu_data_in; 		-- When CPU is reading, cpu_data_in goes into cpu_data
	cpu_data_out <= "ZZZZZZZZ" when cpu_rd_n = '0' and cpu_wr_n = '1' else cpu_data;		-- When CPU is writting, cpu_data goes to cpu_data_out
	
	-- NIOS data buffer --
	nios_data <= "ZZZZZZZZ" when nios_rd_n = '1' and nios_wr_n = '0' else nios_data_in; 	-- when NIOS is reading, nios_data_in goes into nios_data
	nios_data_out <= "ZZZZZZZZ" when nios_rd_n = '0' and nios_wr_n = '1' else nios_data; 	-- When NIOS is writting, nios_data goes to nios_data_out
	
	-- Read buffer
	data_in <= 		rom_data_out when read_en = '1' 			and rom_en = '1' else
						cpu_pixel_data_out when read_en = '1' 	and cpu_pixel_en = '1' else
						cpu_color_data_out when read_en = '1'	and cpu_color_en = '1' else
						ram_data_out when read_en = '1'			and ram_en = '1' else
						
						-- peripherals --
						nios_data_out when read_en = '1'			and nios_en = '1' else -- only possible when T80 has bus access
						ula_data_out when read_en = '1' 			and ula_en = '1' else
						kemp_data_out when read_en = '1'			and kemp_en = '1' else
						ula_read_bus when read_en = '1'			and iorq_n = '0' else --and address = x"FF" else -- an attempt to recreate the floating bus behavior
						(others => '0') when global_reset = '1' else
						"ZZZZZZZZ";
	
	
	-- global signals (NIOS vs T80) --
	cpu_data_in <= data_in;
	nios_data_in <= data_in;
	
	-- DMA mux --
	read_en <= (not cpu_rd_n) WHEN cpu_busak_n = '1' else (not nios_rd_n);
	write_en <= (not cpu_wr_n) WHEN cpu_busak_n = '1' else (not nios_wr_n);
	mreq_n <= cpu_mreq_n WHEN cpu_busak_n = '1' else nios_mreq_n;
	iorq_n <= cpu_iorq_n WHEN cpu_busak_n = '1' else nios_iorq_n;
	data_out <= cpu_data_out WHEN cpu_busak_n = '1' else nios_data_out;
	address <= cpu_address WHEN cpu_busak_n = '1' else nios_address;

	
	-- TEST signals --
	ula_tclka_n <= not (iorq_n or mreq_n or cpu_rd_n or not cpu_wr_n);
	ula_tclkb_n <= not (iorq_n or mreq_n or not cpu_rd_n or cpu_wr_n);
end Behavior;
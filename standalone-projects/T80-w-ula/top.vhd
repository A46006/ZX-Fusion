library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
	port (
		CLOCK_50 : IN std_logic;
		SW : in std_logic_vector(17 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(7 downto 0);
		
		KEYB_ADDR : out std_logic_vector(7 downto 0);
		KEYB_DATA : in std_logic_vector(4 downto 0);
		
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6));
end top;

architecture Behavior of top is
	COMPONENT conv_7seg IS
		PORT ( number : IN STD_LOGIC_VECTOR(7 downto 0);
			 num1, num0 : OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	-------------------
	-- RESET COUNTER --
	-------------------
	component reset_counter IS
		PORT
		(
			aclr		: IN STD_LOGIC ;
			clk_en	: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
		);
	END component;
	
	component CLK_CTR is
		PORT
		(
			aclr		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
		);
	end component;
	
--	component pll is
--		PORT
--		(
--			areset		: IN STD_LOGIC  := '0';
--			inclk0		: IN STD_LOGIC  := '0';
--			c0				: OUT STD_LOGIC ;
--			locked		: OUT STD_LOGIC 
--		);
--	end component;
	
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
			D                       : inout std_logic_vector(7 downto 0));
	end component;
	
	component ula_top is
		port(
			CLK			: in std_logic;
			nRESET		: in std_logic;
			
			-- PORT --
			D_IN			:	in	std_logic_vector(7 downto 0);
			D_OUT			:	out	std_logic_vector(7 downto 0);
			ENABLE		:	in	std_logic;
			WR_e			:	in	std_logic;
			
			BORDER_OUT	:	out	std_logic_vector(2 downto 0);
			EAR_OUT		:	out	std_logic;
			MIC_OUT		:	out std_logic;
			
			KEYB_IN		:	in 	std_logic_vector(4 downto 0);
			EAR_IN		:	in	std_logic;
			
			-- COUNT --
			nTCLKA		: in	std_logic; -- Upper Counter Stage Test Clock = nIOREQ and nMREQ and nRD and !nWR
			nTCLKB		: in	std_logic; -- Flash Counter Test Clock = nIOREQ and nMREQ and !nRD and nWR
			
			MREQ_n		: in	std_logic;
			IOREQ_n		: in std_logic;

			TOP_ADDRESS	: in	std_logic_vector(1 downto 0);
			
			nINT			: out	std_logic; -- Interrupt
			CPU_CLK		: out	std_logic; -- 3.5MHz
			FLASH_CLK	: out std_logic -- 1.56 Hz
			--IOREQGTW3_n	: out std_logic
		);
	end component;
	
	-- COUNTER RELATED
	signal count : std_logic_vector(2 downto 0) := "000"; -- minimum of 3 clocks for reset
	signal global_reset : std_logic;
	
	-- DIRECTLY CPU RELATED
	signal cpu_clk, bus_rq_n : std_logic := '1';
	signal m1_n, cpu_mreq_n, cpu_rd_n, cpu_wr_n, mem_refresh_n, halt_n, busak_n, read_en, write_en: std_logic;
	signal cpu_address, address : std_logic_vector(15 downto 0) := x"0000";
	signal cpu_data, cpu_data_i, cpu_data_o, data_in, data_out : std_logic_vector(7 downto 0) := x"00";
	
	signal cpu_iorq_n : std_logic := '1';
	
	signal data_view : std_logic_vector(7 downto 0);
	
	signal nmi_n : std_logic := '1';
	signal cpu_int_n : std_logic := '1';
	
	signal ula_clk : std_logic := '0';
	signal pll_locked : std_logic;
	
	signal ula_en : std_logic := '0';
	signal ula_data_out : std_logic_vector(7 downto 0) := (others => '0');
	signal ula_border_out : std_logic_vector(2 downto 0);
	signal ula_speaker_out, ula_mic_out, ula_ear_in : std_logic := '0';
	signal ula_tclka_n, ula_tclkb_n, ula_in_iorq_n : std_logic;
	signal ula_a : std_logic_vector(1 downto 0);
	signal flash_clk : std_logic;
	
	signal keyboard_data_out : std_logic_vector(4 downto 0) := "10111";
	
	signal mreq_n, iorq_n : std_logic := '1';
	
	signal video_clock : std_logic := '0';
	-- "NIOS" --
	signal nios_en : std_logic := '0';
	signal nios_data_out, nios_data_in : std_logic_vector(7 downto 0) := x"00";
	signal nios_address : std_logic_vector(15 downto 0) := x"0000";
	signal nios_rd_n, nios_wr_n, nios_mreq_n, nios_iorq_n : std_logic := '1';
	
	-- ROM --
	signal rom_address : std_logic_vector(13 downto 0);
	signal rom_en : std_logic;
	signal rom_data_in : std_logic_vector(7 downto 0) := (others => '0'); -- Is this necessary?
	signal rom_data_out : std_logic_vector(7 downto 0);
	
	-- Remaining RAM --
	signal ram_address : std_logic_vector(15 downto 0);
	signal ram_en : std_logic;
	signal ram_data_out : std_logic_vector(7 downto 0);
	
	-- reset counter --
	signal ctr_en : std_logic := '1';
	signal rst_ctr_num : std_logic_vector(9 downto 0) := (others => '0');
	signal pll_reset, ula_reset_n, cpu_reset_n : std_logic := '1';
	
	
	signal clk_ctr_num : std_logic_vector(2 downto 0) := (others => '0');
	
begin
	address_low : conv_7seg port map (address(7 downto 0), HEX1, HEX0);
	address_high : conv_7seg port map (address(15 downto 8), HEX3, HEX2);
	data_7seg : conv_7seg port map(data_view, HEX7, HEX6);
	HEX5 <= "0001000";
	HEX4 <= "1111110";
		
	KEYB_ADDR <= address(15 downto 8);
	keyboard_data_out <= KEYB_DATA;
	
	---------
	-- PLL --
	---------
--	main_pll : pll port map (
--			areset	=> pll_reset,
--			inclk0	=> CLOCK_50,
--			c0			=> ula_clk,	      -- 7 MHz
--			locked	=> pll_locked
--		);

	ula_clk <= clk_ctr_num(2);
	main_pll : CLK_CTR port map (
			aclr	=> pll_reset,
			clock	=> CLOCK_50,
			q		=> clk_ctr_num	      -- 6.25 MHz
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
	

	z80 : T80a port map (
			RESET_n => cpu_reset_n, CLK_n => cpu_clk, WAIT_n => '1', INT_n => cpu_int_n, NMI_n => nmi_n, BUSRQ_n => bus_rq_n,
			M1_n => m1_n, MREQ_n => cpu_mreq_n, IORQ_n => cpu_iorq_n, RD_n => cpu_rd_n, WR_n => cpu_wr_n, RFSH_n => mem_refresh_n,
			HALT_n => halt_n, BUSAK_n => busak_n,
			A => cpu_address, D => cpu_data);
			
	ula : ula_top port map (
			CLK			=> ula_clk,
			nRESET		=> ula_reset_n,
			
			-- PORT --
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
			CPU_CLK		=> cpu_clk,
			FLASH_CLK	=> flash_clk
	);
	ula_in_iorq_n <= iorq_n OR address(0); -- spider modification (TODO make sure this is necessary)
	ula_a <= address(15) & address(14);


	ula_en <= '1' when iorq_n = '0' and cpu_mreq_n = '1' and address(7 downto 0) = X"FE" else '0';
	-- MEMORY --
	
	-- '1' when in the range 0x0000 to 0x3FFF
	rom_en <= not (mreq_n or cpu_rd_n or address(15) or address(14));--(not mreq_n) and (not cpu_rd_n)
	
	
	-- '1' when mem_req is on but no other memory is being accessed
	ram_en <= (not mreq_n) and (
						address(15) or (address(14) and ( -- 01000000... to 11111111... (0x4000 to 0xFFFF)
							address(13) OR ( -- 01100000... to 11111111... (0x6000 to 0xFFFF)
								(address(12) and address(11)) AND -- 01011000... to 11111111... (0x5800 to 0xFFFF)
								(address(10) or (address(9) and address(8))) -- 01011011... to 11111111... (0x5B00 to 0xFFFF)
							)
						))
					);
	

	
	cpu_data <= "ZZZZZZZZ" when cpu_rd_n = '1' and cpu_wr_n = '0' else cpu_data_i; -- READ
	cpu_data_o <= "ZZZZZZZZ" when cpu_rd_n = '0' and cpu_wr_n = '1' else cpu_data; -- WRITE

	
	----------------------
	-- Memory Addresses --
	----------------------
	
	rom_address <= address(13 downto 0) when rom_en = '1' 
											else (others => '0');
											
	ram_address <= (address-x"5B00") when ram_en = '1'
											else (others => '0');
											
											
	
			
	--clock_n <= KEY(0);
	global_reset <= not KEY(1);
	
	data_view <= cpu_data when cpu_rd_n = '0' and cpu_wr_n = '1' else cpu_data_o;
	--LEDG <= data_view;
	
	
	bus_rq_n <= not SW(17);
	nmi_n <= not SW(16);
	--nios_rd_n <= not SW(15);
	nios_wr_n <= not SW(15);
	nios_mreq_n <= not SW(14);
	--nios_iorq_n <= not SW(12);
	--int_n <= not SW(15);
	
	nios_data_out <= SW(7 downto 0);
	nios_address(5 downto 0) <= SW(13 downto 8);
	nios_address(15 downto 6) <= "1111111111";
	LEDG(7 downto 0) <= nios_data_in;
	
	
	nios_data_in <= data_in;
	cpu_data_i <= data_in;
	
	data_in <= 	rom_data_out when read_en = '1' 			and rom_en = '1' else
					ram_data_out when read_en = '1' 		and ram_en = '1' else
					nios_data_out when read_en = '1'		and nios_en = '1' else
					ula_data_out when read_en = '1'		and ula_en = '1' else
					(others => '0') when global_reset = '1' else
					"ZZZZZZZZ";
	
	LEDR(15 downto 0) <= address;
	
	--LEDG(0) <= not busak_n;
	--LEDG(1) <= not halt_n;

	LEDR(17) <= not halt_n;
	LEDR(16) <= not busak_n;

	--cpu_data_i <= SW(7 downto 0);
	
	-------------------
	-- RESET COUNTER --
	-------------------
	ctr_en <= not rst_ctr_num(9);
	reseter : reset_counter port map(
			aclr			=> global_reset,
			clk_en		=> ctr_en,
			clock			=> CLOCK_50,
  			q				=> rst_ctr_num
		);
		
		
	-- Restart order matters:
	-- PLL first, since it gives off the clocks
	-- CPU last (at least not during ULA reset, since this gives the CPU its clocks)
	
	pll_reset <= '1' when rst_ctr_num(9 downto 3)= "0000001" else '0';
	ula_reset_n <= '0' when rst_ctr_num(9 downto 5) = "00001" else '1';
	cpu_reset_n <= '0' when rst_ctr_num(9 downto 7) = "001" else '1';
	
	-- DMA mux --
	read_en <= (not cpu_rd_n) WHEN busak_n = '1' else (not nios_rd_n);
	write_en <= (not cpu_wr_n) WHEN busak_n = '1' else (not nios_wr_n);
	mreq_n <= cpu_mreq_n WHEN busak_n = '1' else nios_mreq_n;
	iorq_n <= cpu_iorq_n WHEN busak_n = '1' else nios_iorq_n;
	data_out <= cpu_data_o WHEN busak_n = '1' else nios_data_out;
	address <= cpu_address WHEN busak_n = '1' else nios_address;
	
	-- TEST signals --
	ula_tclka_n <= not (cpu_iorq_n or cpu_mreq_n or cpu_rd_n or not cpu_wr_n);
	ula_tclkb_n <= not (cpu_iorq_n or cpu_mreq_n or not cpu_rd_n or cpu_wr_n);
end Behavior;

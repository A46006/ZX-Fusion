library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity video_tb is
end video_tb;
---
architecture tb_arch of video_tb is

	component video is
		port(
			CLOCK, FLASH_CLK, RESET : IN std_logic; -- 65MHz video clock
			PIXEL_DATA, COLOR_DATA	: IN std_logic_vector(7 downto 0);
			BORDER : in std_logic_vector(2 downto 0);
			BORDER_EN : in std_logic;
			PIXEL_RE, COLOR_RE : out std_logic;
			PIXEL_ADDR : OUT std_logic_vector(12 downto 0);
			COLOR_ADDR : out std_logic_vector(9 downto 0);
			VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N : out STD_LOGIC;
			VGA_CLK : OUT std_logic; -- 65MHz reversed phase
			VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(7 downto 0)
		);
	end component;
	
	component pixel_video_ram IS
		PORT
		(
			-- a -> accessed by video
			-- b -> accessed by CPU (UNUSED IN THIS TB)
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
	
	component color_video_ram IS
	PORT
	(
		-- a -> accessed by video
		-- b -> accessed by CPU (UNUSED IN THIS TB)
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


	signal clk, clock, flash_clock, flash_clk : std_logic := '0';
	signal pixel_en, col_en : std_logic;
	signal pixel_data, col_data : std_logic_vector(7 downto 0) := x"00";
	signal pixel_addr : std_logic_vector(12 downto 0) := (others => '0');
	signal col_addr : std_logic_vector(9 downto 0) := (others => '0');
	
	signal border : std_logic_vector(2 downto 0) := (others => '1');
	signal border_en : std_logic := '0';
	
	-- REG --
	signal h_sync_reg, v_sync_reg : std_logic;
	
--	signal position_addr : integer range 0 to 6144 := 0;
--	signal color_addr : integer range 0 to 768 := 0;

	signal red, green, blue : STD_LOGIC_vector(7 downto 0);

	signal h_sync, v_sync, n_blank, n_sync, vga_clk : std_logic;
	signal x, y : integer;

	signal reset : std_logic;
	
	-- UNUSED
	signal cpu_color_data, cpu_pixel_data : std_logic_vector(7 downto 0);
begin
	clock <= not clock after 15.38461538461538 ns;
	clk <= clock;
	flash_clock <= not flash_clock after 641.02564102564102564102564102564 ms;
	flash_clk <= flash_clock;
	
	-----------
	-- VIDEO --
	-----------
	uut : video port map(
			CLOCK 		=> clk,
			FLASH_CLK	=> flash_clk,
			RESET 		=> reset,
			-- Memory Data --
			PIXEL_DATA	=> pixel_data,
			COLOR_DATA	=> col_data,
			-- Border --
			BORDER 		=> border,
			BORDER_EN	=> border_en,
			-- Memory Enables --
			PIXEL_RE		=> pixel_en,
			COLOR_RE		=> col_en,
			-- Memory Addresses --
			PIXEL_ADDR	=> pixel_addr,
			COLOR_ADDR	=> col_addr,
			-- VGA Signals --
			VGA_HS		=> h_sync,
			VGA_VS		=> v_sync,
			VGA_BLANK_N	=> n_blank,
			VGA_SYNC_N	=> n_sync,
			VGA_CLK		=> vga_clk,
			VGA_R			=> red,
			VGA_G			=> green,
			VGA_B			=> blue
		);
		
	----------------
	-- PIXEL RAM --
	----------------
	pixel_memory : pixel_video_ram port map(
			-- VIDEO --								-- CPU --
			address_a 	=> pixel_addr, 		address_b 	=> "0000000000000",
			clock_a 		=> clk, 					clock_b 		=> '0',
			data_a 		=> (others => 'Z'), 	data_b 		=> x"00",
			enable_a 	=> pixel_en, 					enable_b 	=> '0',
			wren_a 		=> '0',					wren_b		=> '0',
			q_a			=> pixel_data, 		q_b			=> cpu_pixel_data
		);
		
	---------------
	-- COLOR RAM --
	---------------
	color_memory : color_video_ram port map(
			-- VIDEO --									-- CPU --
			address_a	=> col_addr,			address_b => "0000000000",
			clock_a 		=> clk, 					clock_b 		=> '0',
			data_a 		=> (others => 'Z'), 	data_b 		=> x"00",
			enable_a		=> col_en,					enable_b		=> '0',
			wren_a 		=> '0',					wren_b		=> '0',
			q_a			=> col_data,			q_b			=> cpu_color_data
		);

	
	-- testbench process
	video_tb : process
	begin
	
		wait for 100 ns;
	
		reset <= '1' after 0 ns, '0' after 101 ns;
		
		wait for 35 ms;
		assert false report "fim da simulação!" severity warning;
		wait; -- will wait forever
	end process;
	
end tb_arch;

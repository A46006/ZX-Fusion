library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
	port (
		CLOCK_50 : IN std_logic;
		----------- VGA ------------
		VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK : out STD_LOGIC;
		VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(7 downto 0);
		SW : in std_logic_vector(17 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(17 downto 0));
end top;

architecture Behavior of top is
	component pll IS
	PORT
	(
		areset		: IN STD_LOGIC  := '0';
		inclk0		: IN STD_LOGIC  := '0'; -- 50 MHz
		c0		: OUT STD_LOGIC ; -- 3.5 MHz
		c1		: OUT STD_LOGIC ; -- 14 MHz
		c2		: OUT STD_LOGIC ; -- 65 MHz
		locked		: OUT STD_LOGIC 
	);
	END component;
	
	--component memory_flashing IS
	--	PORT(
	--		ADDRESS		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
	--		CLOCK		: IN STD_LOGIC;
	--		DATA		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	--		WREN		: IN STD_LOGIC;
	--		Q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
	--END component;
	
	
	component position_video_ram IS
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
		-- b -> accessed by CPU
		address_a		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		address_b		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
		clock_a		: IN STD_LOGIC  := '1';
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component;

	
	component video is
		port(
			CLOCK, RESET : IN std_logic; -- 65MHz
			POS_DATA, COLOR_DATA	: IN std_logic_vector(7 downto 0);
			SCREEN_RE, COLOR_RE : out std_logic;
			POSITION_ADDRESS, COLOR_ADDRESS : OUT std_logic_vector(12 downto 0);
			VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N : out STD_LOGIC;
			VGA_CLK : OUT std_logic; -- 65MHz reverse phase
			VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(7 downto 0));
	end component;
	
	signal cpu_clock, alu_clock, true_clock, cpu_position_mem_access, cpu_color_mem_access, cpu_wren : std_logic := '0';
	signal memory_address : std_logic_vector(15 downto 0);
	signal cpu_position_mem_address, cpu_color_mem_address : std_logic_vector(15 downto 0);
	signal cpu_data : std_logic_vector(7 downto 0);

	signal reset_n, pll_locked, pll_reset : std_logic;
	
	signal video_read_e, color_read_e, video_reset : std_logic := '0';
	signal pos_video_address, col_video_address, position_video_address_in, color_video_address_in : std_logic_vector(12 downto 0);
	signal cpu_pos_data_out, cpu_col_data_out : std_logic_vector(7 downto 0);
	
	signal cpu_position_mem_wren, cpu_color_mem_wren : std_logic := '0';
	
	signal pos_data_in, col_data_in, pos_data_out, col_data_out : std_logic_vector(7 downto 0);
	
begin
	
	main_pll : pll port map (
						areset => pll_reset,
						inclk0 => CLOCK_50,
						c0 => cpu_clock,
						c1 => alu_clock,
						c2 => true_clock,
						locked => pll_locked);
	
	
	-- '1' when in the range 0x4000 to 0x4fff OR in the range 0x5000 to 0x57FF
	cpu_position_mem_access <= '1' when (memory_address(15 downto 12) = "0100") or (memory_address(15 downto 11) = "01010") else '0';
	
	
	--cpu_color_mem_access <= memory_address(15 downto 8) = "01011000" or memory_address(15 downto 8) = "01011001" or memory_address(15 downto 8) = "01011010";
	-- '1' when in the range 0x5800 to 0x5AFF
	cpu_color_mem_access <= '1' when ((memory_address(15 downto 10) = "010110") and not (memory_address(9) = '1' and memory_address(8) = '1')) else '0';
	
	
	
	cpu_position_mem_wren <= cpu_wren and cpu_position_mem_access;
	cpu_color_mem_wren <= cpu_wren and cpu_color_mem_access;

	cpu_position_mem_address <= (memory_address - x"4000") when cpu_position_mem_access = '1'
											else x"0000";
											
	cpu_color_mem_address <= (memory_address - x"5800") when cpu_color_mem_access = '1'
											else x"0000";

	-- mem out -> cpu in
	cpu_data <= cpu_pos_data_out when cpu_position_mem_access = '1' and not cpu_position_mem_wren = '1' else
					cpu_col_data_out when cpu_color_mem_access = '1' and not cpu_color_mem_wren = '1';

	-- cpu out -> mem in
	pos_data_in <= cpu_data when cpu_position_mem_access = '1' and cpu_position_mem_wren = '1';
	col_data_in <= cpu_data when cpu_color_mem_access = '1' and cpu_color_mem_wren = '1';
					
	
	pos_video_mem : position_video_ram port map (
								address_a => position_video_address_in, 	address_b => cpu_position_mem_address(12 downto 0), -- CPU ADDRESS RANGE 0x4000 to 0x57FF
								clock_a => true_clock, 	clock_b => cpu_clock,
								data_a => x"00", 	data_b => pos_data_in,
								wren_a => '0', 	wren_b => cpu_position_mem_wren,
								q_a => pos_data_out, 	q_b => cpu_pos_data_out);
								
	col_video_mem : color_video_ram port map (
								address_a => color_video_address_in(9 downto 0), 	address_b => cpu_color_mem_address(9 downto 0), -- CPU ADDRESS RANGE 0x4000 to 0x57FF
								clock_a => true_clock, 	clock_b => cpu_clock,
								data_a => x"00", 	data_b => col_data_in,
								wren_a => '0', 	wren_b => cpu_color_mem_wren,
								q_a => col_data_out, 	q_b => cpu_col_data_out);

								
	grafx : video port map(
						CLOCK => true_clock, RESET => video_reset,
						POS_DATA => pos_data_out, COLOR_DATA => col_data_out,
						SCREEN_RE => video_read_e, COLOR_RE => color_read_e,
						POSITION_ADDRESS => pos_video_address, COLOR_ADDRESS => col_video_address,
						VGA_HS => VGA_HS, VGA_VS => VGA_VS, VGA_BLANK_N => VGA_BLANK_N, VGA_SYNC_N => VGA_SYNC_N,
						VGA_CLK => VGA_CLK,
						VGA_R => VGA_R, VGA_G => VGA_G, VGA_B => VGA_B);
						
	pll_reset <= not SW(9);
	LEDR(0) <= pll_reset;
	
	reset_n <= not (pll_reset or not pll_locked);
	LEDR(1) <= not reset_n;
	LEDR(2) <= pll_locked;
	LEDR(3) <= video_read_e;
	--LEDR(17 downto 5) <= video_address;
	
	position_video_address_in <= pos_video_address when video_read_e = '1';
	color_video_address_in <= col_video_address when color_read_e = '1';
	
	
end Behavior;
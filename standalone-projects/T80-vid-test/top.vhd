library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
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
		LEDR : out std_logic_vector(17 downto 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6));
end top;

architecture Behavior of top is
	COMPONENT conv_7seg IS
		PORT ( number : IN STD_LOGIC_VECTOR(7 downto 0);
			 num1, num0 : OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
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
			
			--DEBUG_PC	: out std_logic_vector(15 downto 0));
	end component;
	
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
	
	----- CPU -----
	signal cpu_clock, alu_clock, true_clock, reset,
			 cpu_position_mem_access, cpu_color_mem_access, rom_access, ram_access : std_logic := '0';
	signal m1, mem_req_n, io_req_n, read_n, write_n : std_logic;
	signal mem_refresh_n : std_logic; -- USELESS?
	signal halt_n, busak_n : std_logic;
	signal address : std_logic_vector(15 downto 0);
	signal cpu_position_mem_address, cpu_color_mem_address, cpu_ram_address : std_logic_vector(15 downto 0);
	signal cpu_data, cpu_data_o, cpu_data_i, rom_data_o, ram_data_o : std_logic_vector(7 downto 0);
	
	signal data_view : std_logic_vector(7 downto 0);
	
	----- CPU reset counter -----
	signal count : std_logic_vector(2 downto 0); -- minimum of 3 clocks for reset
	signal reset_ctr_start : std_logic := '1';
	signal reset_ctr_manual : std_logic;
	
	----- pll -----
	signal pll_reset_n, pll_locked, pll_reset : std_logic;
	
	--
	signal video_read_e, color_read_e, video_reset : std_logic := '0';
	signal pos_video_address, col_video_address, position_video_address_in, color_video_address_in : std_logic_vector(12 downto 0);
	signal cpu_pos_data_out, cpu_col_data_out : std_logic_vector(7 downto 0);
	
	signal cpu_position_mem_wren, cpu_color_mem_wren : std_logic := '0';
	
	signal pos_data_in, col_data_in, pos_data_out, col_data_out : std_logic_vector(7 downto 0);
begin
	----- 7 SEGMENT -----
	address_low : conv_7seg port map (address(7 downto 0), HEX1, HEX0);
	address_high : conv_7seg port map (address(15 downto 8), HEX3, HEX2);
	data_7seg : conv_7seg port map(data_view, HEX7, HEX6);
	HEX5 <= "0001000";
	HEX4 <= "1111110";
	data_view <= cpu_data when read_n = '0' and write_n = '1' else cpu_data_o;
	
	main_pll : pll port map (
						areset => pll_reset,
						inclk0 => CLOCK_50,
						c0 => cpu_clock,
						c1 => alu_clock,
						c2 => true_clock,
						locked => pll_locked);

	-- '1' when in the range 0x0000 to 0x3FFF
	rom_access <= '0' when mem_req_n = '1' or read_n = '1' or write_n = '0' else
						'1' when address(15 downto 14) = "00";
	
	-- '1' when in the range 0x4000 to 0x4fff OR in the range 0x5000 to 0x57FF
	cpu_position_mem_access <= '0' when mem_req_n = '1' else
										'1' when (address(15 downto 12) = "0100") or (address(15 downto 11) = "01010");
	
	-- '1' when in the range 0x5800 to 0x5AFF
	cpu_color_mem_access <= '0' when mem_req_n = '1' else
									'1' when ((address(15 downto 10) = "010110") and not (address(9) = '1' and address(8) = '1'));
	
	-- '1' when mem_req is on but no other memory is being accessed
	ram_access <= '0' when mem_req_n = '1' else
						'1' when rom_access = '0' and cpu_position_mem_access = '0' and cpu_color_mem_access = '0';
	
	-- write enables for position and attribute data memories
	cpu_position_mem_wren <= '1' when write_n = '0' and cpu_position_mem_access = '1' else '0';
	cpu_color_mem_wren <= '1' when write_n = '0' and cpu_color_mem_access = '1' else '0';

	-- addresses for position and attribute data memories
	cpu_position_mem_address <= (address - x"4000") when cpu_position_mem_access = '1'
											else x"0000";
											
	cpu_color_mem_address <= (address - x"5800") when cpu_color_mem_access = '1'
											else x"0000";
											
	cpu_ram_address <= (address-x"5B00") when ram_access = '1'
											else x"0000";
											
	-- CPU data bus
	cpu_data <= "ZZZZZZZZ" when read_n = '1' and write_n = '0' else cpu_data_i; -- READ
	cpu_data_o <= "ZZZZZZZZ" when read_n = '0' and write_n = '1' else cpu_data; -- WRITE
	
				
	-- CPU data bus input switch
	process(rom_access, cpu_position_mem_access, cpu_color_mem_access, ram_access,
				rom_data_o, cpu_pos_data_out, cpu_col_data_out, ram_data_o)
	begin
		if (rom_access = '1') then
			cpu_data_i <= rom_data_o;
		elsif (cpu_position_mem_access = '1') then
			cpu_data_i <= cpu_pos_data_out;
		elsif (cpu_color_mem_access = '1') then
			cpu_data_i <= cpu_col_data_out;
		elsif (ram_access = '1') then
			cpu_data_i <= ram_data_o;
		else
			cpu_data_i <= "ZZZZZZZZ"; -- SHOULD IT BE DIFFERENT?
		end if;
	end process;
	
	pos_data_in <= cpu_data_o when cpu_position_mem_access = '1' and cpu_position_mem_wren = '1';
	col_data_in <= cpu_data_o when cpu_color_mem_access = '1' and cpu_color_mem_wren = '1';
	
	-- NOT NECESSARY RIGHT? CLKEN WORKS
	--ram_data_in <= cpu_data_o when ram_access = '1' and
	
	z80 : T80a port map (
				RESET_n => not reset, CLK_n => not cpu_clock, WAIT_n => '1', INT_n => '1', NMI_n => '1', BUSRQ_n => '1',
				M1_n => m1, MREQ_n => mem_req_n, IORQ_n => io_req_n, RD_n => read_n, WR_n => write_n, RFSH_n => mem_refresh_n,
				HALT_n => halt_n, BUSAK_n => busak_n,
				A => address, D => cpu_data);
	
	the_rom : rom port map (
							address => address(13 downto 0), 
							clken => rom_access, clock => CLOCK_50, -- SHOULD I MAKE IT A DIFFERENT CLOCK?
							data => cpu_data, rden => not read_n, wren => '0', -- ITS ROM SO WRITE SHOULD BE IMPOSSIBLE, right?
							q => rom_data_o);
	
	-- SHOULD PROBABLY CHANGE TO INCLUDE CLOCK ENABLE
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

	ram : remaining_ram port map (
							address => cpu_ram_address, 
							clken => ram_access, clock => CLOCK_50, -- SHOULD I MAKE IT A DIFFERENT CLOCK?
							data => cpu_data, rden => not read_n, wren => not write_n,
							q => ram_data_o);
								
	grafx : video port map(
						CLOCK => true_clock, RESET => video_reset,
						POS_DATA => pos_data_out, COLOR_DATA => col_data_out,
						SCREEN_RE => video_read_e, COLOR_RE => color_read_e,
						POSITION_ADDRESS => pos_video_address, COLOR_ADDRESS => col_video_address,
						VGA_HS => VGA_HS, VGA_VS => VGA_VS, VGA_BLANK_N => VGA_BLANK_N, VGA_SYNC_N => VGA_SYNC_N,
						VGA_CLK => VGA_CLK,
						VGA_R => VGA_R, VGA_G => VGA_G, VGA_B => VGA_B);
						
	pll_reset <= SW(9);
	LEDR(0) <= pll_reset;
	
	pll_reset_n <= not (pll_reset or not pll_locked);
	LEDR(1) <= not pll_reset_n;
	
	position_video_address_in <= pos_video_address when video_read_e = '1';
	color_video_address_in <= col_video_address when color_read_e = '1';
	
	----- CPU RESET COUNTER -----
	process(cpu_clock, reset_ctr_manual)
	begin
		if (rising_edge(cpu_clock)) then
			if ((reset_ctr_start = '1' or reset_ctr_manual = '1') and reset = '0') then -- beginning, turn on reset
				reset <= '1';
				
			elsif (count(2) = '0') then
				count <= unsigned(count) + '1'; 
			elsif (count(2) = '1' and reset <= '1') then
				reset <= '0';
				reset_ctr_start <= '0';
			end if;
		end if;
	end process;
	
	reset_ctr_manual <= not KEY(1);
	video_reset <= not KEY(1);
	
end Behavior;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interpreter_tb is
end interpreter_tb;
---
architecture behav of interpreter_tb is
	component data_interpreter
			port(
			MEM_CLK, PIXEL_CLK, DISPLAY_E: IN   STD_LOGIC;
			POS_DATA, COL_DATA : in std_logic_vector(7 downto 0);
			POS_ADDR, COL_ADDR : out std_logic_vector(12 downto 0);
			READ_E : out std_logic;
			R, G, B : OUT STD_LOGIC_VECTOR(1 downto 0));
	end component;

	component pos_vram is
		port(
			address: in integer range 0 to 6144;
			data_out: out std_logic_vector(7 downto 0));
	end component;

	component col_vram is
		port(
			address: in integer range 0 to 768;
			data_out: out std_logic_vector(7 downto 0));
	end component;


	signal clk, rev_clk, vga_clk, re : std_logic := '0';
	signal disp_e : std_logic := '1';
	signal pos_data, col_data : std_logic_vector(7 downto 0) := x"00";
	signal pos_addr, col_addr : std_logic_vector(12 downto 0) := (others => '0');

	signal clk_ctr : integer range 0 to 3 := 0;
	
	signal position_addr : integer range 0 to 6144 := 0;
	signal color_addr : integer range 0 to 768 := 0;

	signal red, green, blue : STD_LOGIC_VECTOR(1 downto 0) := "00";
	
begin
	rev_clk <= not clk;
	position_addr <= to_integer(unsigned(pos_addr));
	color_addr <= to_integer(unsigned(col_addr));

   comp : data_interpreter port map (
			MEM_CLK => clk,
			PIXEL_CLK => rev_clk,
			DISPLAY_E => disp_e,
			POS_DATA => pos_data, COL_DATA => col_data,
			POS_ADDR => pos_addr, COL_ADDR => col_addr,
			READ_E => re,
			R => red, 
			G => green, 
			B => blue);

	positions : pos_vram port map (position_addr, pos_data);
	colors : col_vram port map (color_addr, col_data);
			
    -- clk
    process
    begin
		clk <= '0';
		wait for 15.38461538461538 ns;
		clk <= '1';
		wait for 15.38461538461538 ns;
    end process;
end behav;


-------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity pos_vram is
	port(
		address: in integer range 0 to 6144;
		data_out: out std_logic_vector(7 downto 0));
end pos_vram;

architecture Behavior of pos_vram is

	type memory is array (0 to 6144) of STD_LOGIC_VECTOR(7 downto 0);
	
	signal myvram: memory;
	
	attribute ram_init_file: string;
	attribute ram_init_file of myvram: signal is "file/screenData.hex";
begin
		data_out <= myvram(address);
end Behavior;


-------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity col_vram is
	port(
		address: in integer range 0 to 768;
		data_out: out std_logic_vector(7 downto 0));
end col_vram;

architecture Behavior of col_vram is

	type memory is array (0 to 768) of STD_LOGIC_VECTOR(7 downto 0);
	
	signal myvram: memory;
	
	attribute ram_init_file: string;
	attribute ram_init_file of myvram: signal is "file/colorDataWFakeFlash.hex";
begin
		data_out <= myvram(address);
end Behavior;
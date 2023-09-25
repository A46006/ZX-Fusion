library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity interpreter_tb is
end interpreter_tb;
---
architecture behav of interpreter_tb is

	component vga_controller is
		PORT(
			pixel_clk : IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
			reset_n   : IN   STD_LOGIC;  --active low asycnchronous reset
			h_sync    : OUT  STD_LOGIC;  --horiztonal sync pulse
			v_sync    : OUT  STD_LOGIC;  --vertical sync pulse
			disp_ena  : OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)
			column    : OUT  INTEGER;    --horizontal pixel coordinate
			row       : OUT  INTEGER;    --vertical pixel coordinate
			n_blank   : OUT  STD_LOGIC;  --direct blacking output to DAC
			n_sync    : OUT  STD_LOGIC); --sync-on-green output to DAC
		end component;


	component data_interpreter is
		port(
			MEM_CLK, PIXEL_CLK, FRAME_CLK, DISPLAY_E: IN   STD_LOGIC;
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


	signal clk, rev_clk, vga_clk, flash_clk, re : std_logic := '0';
	signal disp_e : std_logic := '1';
	signal pos_data, col_data : std_logic_vector(7 downto 0) := x"00";
	signal pos_addr, col_addr : std_logic_vector(12 downto 0) := (others => '0');

	signal clk_ctr : integer range 0 to 3 := 0;
	
	signal position_addr : integer range 0 to 6144 := 0;
	signal color_addr : integer range 0 to 768 := 0;

	signal red, green, blue : STD_LOGIC_VECTOR(1 downto 0) := "00";

	signal h_sync, v_sync, disp_ena, n_blank, n_sync : std_logic;
	signal x, y : integer;

	signal flash_ctr : integer range 0 to 18 := 0;

begin
	rev_clk <= not clk;
	position_addr <= to_integer(unsigned(pos_addr));
	color_addr <= to_integer(unsigned(col_addr));

	controller : vga_controller port map (
						pixel_clk => rev_clk,
						reset_n => '1',
						h_sync => h_sync,
						v_sync => v_sync,
						disp_ena => disp_ena,
						column => x,
						row => y,
						n_blank => n_blank,
						n_sync => n_sync);
   comp : data_interpreter port map (
			MEM_CLK => clk,
			PIXEL_CLK => rev_clk,
			FRAME_CLK => flash_clk,
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

	process(clk) is
	begin
		if(rising_edge(clk)) then
			if (x = 0 and y = 0) then
				if (flash_ctr < 19) then
					flash_ctr <= flash_ctr + 1;
				else
					flash_ctr <= 0;
					flash_clk <= not flash_clk;
				end if;
				
			end if;
		end if;
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
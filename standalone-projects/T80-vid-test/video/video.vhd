library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity video is
	port(
		CLOCK, RESET : IN std_logic; -- 65MHz
		POS_DATA, COLOR_DATA	: IN std_logic_vector(7 downto 0);
		SCREEN_RE, COLOR_RE : out std_logic;
		POSITION_ADDRESS, COLOR_ADDRESS : OUT std_logic_vector(12 downto 0);
		VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N : out STD_LOGIC;
		VGA_CLK : OUT std_logic; -- 65MHz reversed phase
		VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(7 downto 0));
end video;

architecture Behavior of video is
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
			MEM_CLK, PIXEL_CLK, FLASH_CLK, DISPLAY_E, RESET: IN   STD_LOGIC;
			POS_DATA, COL_DATA : in std_logic_vector(7 downto 0);
			POS_ADDR, COL_ADDR : out std_logic_vector(12 downto 0);
			READ_E : out std_logic;
			R, G, B : OUT STD_LOGIC_VECTOR(1 downto 0));
	end component;
	
	--component data_interpreter_remaster is
	--	port(
	--		MEM_CLK, PIXEL_CLK, FLASH_CLK, DISPLAY_E: IN   STD_LOGIC;
	--		POS_DATA, COL_DATA : in std_logic_vector(7 downto 0);
	--		POS_ADDR, COL_ADDR : out std_logic_vector(12 downto 0);
	--		READ_E : out std_logic;
	--		R, G, B : OUT STD_LOGIC_VECTOR(1 downto 0));
	--end component;
		
	signal pixel_clk : std_logic := '0';
	signal clock_ctr : integer range 0 to 3 := 0;
	signal disp_e, read_e : std_logic;
		
	signal x, y : integer;
	signal flash_clk : std_logic;
	signal flash_ctr : integer range 0 to 18 := 0;
	signal r, g, b : STD_LOGIC_VECTOR(1 downto 0) := "00";
begin
	SCREEN_RE <= read_e;
	COLOR_RE <= read_e;
	pixel_clk <= not CLOCK;
	VGA_CLK <= pixel_clk;
	
	controller : vga_controller port map (
						pixel_clk => pixel_clk,
						reset_n => not RESET,
						h_sync => VGA_HS,
						v_sync => VGA_VS,
						disp_ena => disp_e,
						column => x,
						row => y,
						n_blank => VGA_BLANK_N,
						n_sync => VGA_SYNC_N);
						
	interpreter : data_interpreter port map (
						MEM_CLK => CLOCK,
						PIXEL_CLK => pixel_clk,
						FLASH_CLK => flash_clk,
						DISPLAY_E => disp_e,
						RESET => RESET,
						POS_DATA => POS_DATA,
						COL_DATA => COLOR_DATA,
						POS_ADDR => POSITION_ADDRESS(12 downto 0),
						COL_ADDR => COLOR_ADDRESS(12 downto 0),
						READ_E => read_e,
						R => r, 
						G => g, 
						B => b);
						
	--interpreter : data_interpreter_remaster port map (
	--					MEM_CLK => CLOCK,
	--					PIXEL_CLK => pixel_clk,
	--					FLASH_CLK => flash_clk,
	--					DISPLAY_E => disp_e,
	--					POS_DATA => POS_DATA,
	--					COL_DATA => COLOR_DATA,
	--					POS_ADDR => POSITION_ADDRESS(12 downto 0),
	--					COL_ADDR => COLOR_ADDRESS(12 downto 0),
	--					READ_E => read_e,
	--					R => r, 
	--					G => g, 
	--					B => b);
		
	
	-- transforming interpreter's simple output to board's RGB
	VGA_R <= x"00" when r(0) = '0' else
			x"b2" when r(1) = '0' else 
			x"e6";
			
	VGA_G <= x"00" when g(0) = '0' else
			x"b2" when g(1) = '0' else 
			x"e6";
			
	VGA_B <= x"00" when b(0) = '0' else
			x"b2" when b(1) = '0' else 
			x"e6";
	
	process(CLOCK) is
	begin
		if(rising_edge(CLOCK)) then
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
	

end Behavior;
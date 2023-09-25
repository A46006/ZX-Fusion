library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.constants.all;

entity video is
	port(
		CLOCK, FLASH_CLK, RESET : IN std_logic; -- 65MHz video clock
		MODE : in std_logic_vector(1 downto 0);
		PIXEL_DATA, COLOR_DATA	: IN std_logic_vector(7 downto 0);
		BORDER : in std_logic_vector(2 downto 0);
		PIXEL_RE, COLOR_RE : out std_logic;
		PIXEL_ADDR : OUT std_logic_vector(12 downto 0);
		COLOR_ADDR : out std_logic_vector(9 downto 0);
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
			column    : OUT  INTEGER := 0;    --horizontal pixel coordinate
			row       : OUT  INTEGER := 0;    --vertical pixel coordinate
			n_blank   : OUT  STD_LOGIC;  --direct blacking output to DAC
			n_sync    : OUT  STD_LOGIC); --sync-on-green output to DAC
		end component;
		
		
	component data_interpreter is
		port(
			PIXEL_CLK, FLASH_CLK, DISPLAY_E, RESET: IN   STD_LOGIC;
			X, X_INIT, Y, Y_INIT : unsigned(9 downto 0);
			MODE : in std_logic_vector(1 downto 0);
			PIXEL_DATA, COLOR_DATA : in std_logic_vector(7 downto 0);
			PIXEL_ADDR : out std_logic_vector(12 downto 0);
			COLOR_ADDR : out std_logic_vector(9 downto 0);
			READ_E : out std_logic;
			BRIGHT, R, G, B : OUT STD_LOGIC);
	end component;
		
	signal pixel_clk : std_logic := '0';
	signal clock_ctr : integer range 0 to 3 := 0;
	signal disp_e, read_e : std_logic;
		
	signal x_int : integer range 0 to x_int_size;
	signal y_int : integer range 0 to y_int_size;
	signal x, y : unsigned(9 downto 0);	
	
	signal bright, r, g, b : STD_LOGIC := '0';
	signal border_drawing : std_logic;
	signal border_color : std_logic_vector(2 downto 0);
	
	signal h_sync, v_sync, h_sync_reg, v_sync_reg, h_sync_reg_final, v_sync_reg_final, reset_n : std_logic;
	
	signal x_init, y_init, x_end, y_end : unsigned(9 downto 0);
begin
	PIXEL_RE <= read_e;
	COLOR_RE <= read_e;
	
	reset_n <= not RESET;
	
	pixel_clk <= not CLOCK;
	VGA_CLK <= pixel_clk;
	
	border_color <= BORDER;
	
	x <= to_unsigned(x_int, x'length);
	y <= to_unsigned(y_int, y'length);

	controller : vga_controller port map (
						pixel_clk => pixel_clk,
						reset_n => reset_n,
						h_sync => VGA_HS,
						v_sync => VGA_VS,
						disp_ena => disp_e,
						column => x_int,
						row => y_int,
						n_blank => VGA_BLANK_N,
						n_sync => VGA_SYNC_N);
						
	interpreter : data_interpreter port map (
						PIXEL_CLK => pixel_clk,
						FLASH_CLK => FLASH_CLK,
						DISPLAY_E => disp_e,
						RESET => RESET,
						X => x,
						X_INIT => x_init,
						Y => y,
						Y_INIT => y_init,
						MODE => MODE,
						PIXEL_DATA => PIXEL_DATA,
						COLOR_DATA => COLOR_DATA,
						PIXEL_ADDR => PIXEL_ADDR,
						COLOR_ADDR => COLOR_ADDR,
						READ_E => read_e,
						BRIGHT => bright,
						R => r, 
						G => g, 
						B => b);
		
	-- MODE MUX --
	process(MODE)
	begin
		case (MODE) is
			when "11" =>	x_init <= 	x_native_init;
								x_end <= 	x_native_end;
								y_init <=	y_native_init;
								y_end <=		y_native_end;
								
			when "10" =>	x_init <= 	x_2x_init;
								x_end <= 	x_2x_end;
								y_init <=	y_2x_init;
								y_end <=		y_2x_end;	
			
			when others =>	x_init <= 	x_4x_init;
								x_end <= 	x_4x_end;
								y_init <=	y_4x_init;
								y_end <=		y_4x_end; 
		end case;
	end process;
	
--	border_drawing <= '1' when (x=0 or y=0 or x=1023 or y=767) else '0';

   -- X=1023 does not work for some reason (same for y=767)
	-- ex: with red border, that condition removes all red from the whole screen
	border_drawing <= '1' when --MODE /= "00" and 
							(x<=x_init or y<=y_init or x>=x_end or y>=y_end) else '0';
	
	-- transforming interpreter's simple output to board's RGB
	VGA_R <= no_color when disp_e = '0' or 
					(border_drawing = '0' and r = '0') or 
					(border_drawing = '1' and border_color(1) = '0') else
			normal_color when 
					(border_drawing = '0' and bright = '0') or 
					(border_drawing = '1' and border_color(1) = '1') else 
			bright_color;
			
	VGA_G <= no_color when disp_e = '0' or 
					(border_drawing = '0' and g = '0') or 
					(border_drawing = '1' and border_color(2) = '0') else
			normal_color when 
					(border_drawing = '0' and bright = '0') or 
					(border_drawing = '1' and border_color(2) = '1') else 
			bright_color;
			
	VGA_B <= no_color when disp_e = '0' or 
					(border_drawing = '0' and b = '0') or 
					(border_drawing = '1' and border_color(0) = '0') else
			normal_color when 
					(border_drawing = '0' and bright = '0') or 
					(border_drawing = '1' and border_color(0) = '1') else 
			bright_color;
	
	-- sync signal regs --
--	process (pixel_clk, RESET)
--	begin
--		if (rising_edge(pixel_clk)) then
--			if (RESET = '1') then
--				h_sync_reg <= '0';
--				v_sync_reg <= '0';
--				h_sync_reg_final <= '0';
--				v_sync_reg_final <= '0';
--			else
--				h_sync_reg <= h_sync;
--				v_sync_reg <= v_sync;
--				h_sync_reg_final <= h_sync_reg;
--				v_sync_reg_final <= v_sync_reg;
--			end if;
--		end if;
--	end process;
	
end Behavior;
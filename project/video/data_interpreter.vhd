library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
use work.constants.ATT_SIZE;

entity data_interpreter is
	port(
		PIXEL_CLK, FLASH_CLK, DISPLAY_E, RESET: IN   STD_LOGIC;
		X, X_INIT, Y, Y_INIT : unsigned(9 downto 0);
		MODE : in std_logic_vector(1 downto 0);
		PIXEL_DATA, COLOR_DATA : in std_logic_vector(7 downto 0);
		PIXEL_ADDR : out std_logic_vector(12 downto 0);
		COLOR_ADDR : out std_logic_vector(9 downto 0);
		READ_E : out std_logic;
		BRIGHT, R, G, B : OUT STD_LOGIC);
end data_interpreter;

architecture Behavior of data_interpreter is

	-- For PIXEL_MULTIPLIER = 4
	-- F   E   D   C   B  A  9  8        7  6  5  4  3  2  1  0
	-- 13  12  11  10  F  E  D  C  B  A  9  8  7  6  5  4  3  2  1  0
	-- |____| |________| |_______||____||_____________||_______||____|
	-- group   att_row    pix_row  ctr_y    att_col    pixel_col ctr_x
	
	-- Above was for old COUNTER, now X and Y are used, with the order of data being the same:
	-- 9   8   7   6   5  4  3  2  1  0  9  8  7  6  5  4  3  2  1  0
	-- |____| |________| |_______||____||_____________||_______||____|
	-- group   att_row    pix_row  ctr_y    att_col    pixel_col ctr_x
	--|________________________________||_____________________________|
	--						Y											X
	
	signal pixel_info, color_info : std_logic_vector(ATT_SIZE-1 downto 0);
	signal read_enable :std_logic;
		
	-- trans => after subtracting coordinate with beginning of borders
	signal x_trans, y_trans : unsigned(9 downto 0);
	
	signal group_num : std_logic_vector(1 downto 0);		-- current attribute group in a screen
	signal att_row_num : std_logic_vector(2 downto 0);		-- current attribute block row in an attribute group
	signal pix_row_num : std_logic_vector(2 downto 0);		-- current pixel row in an attribute block row
	signal att_col_num : std_logic_vector(4 downto 0);		-- current attribute block in an attribute block row
	signal pix_col_num : std_logic_vector(2 downto 0);		-- current pixel in an attribute block's row of pixels
	
	signal curr_pixel_addr : std_logic_vector(12 downto 0);
	signal curr_color_addr : std_logic_vector(9 downto 0);
	signal read_next, next_was_read : std_logic := '0';
begin

	x_trans <= X - X_INIT when read_next = '0' else (others => '0');
	y_trans <= Y - Y_INIT when read_next = '0' else (Y-Y_INIT)+1;
	
	-- Important location data MUX for address calculating for different modes
	-- Because bit selection expressions must be constant
	process(MODE, x_trans, y_trans)
	begin
		case (MODE) is
			when "11" =>	group_num <= 		std_logic_vector(y_trans(7 downto 6));
								att_row_num <=		std_logic_vector(y_trans(5 downto 3));
								pix_row_num <=		std_logic_vector(y_trans(2 downto 0));
								att_col_num <=		std_logic_vector(x_trans(7 downto 3));
								pix_col_num <=		std_logic_vector(x_trans(2 downto 0));
								
			when "10" =>	group_num <= 		std_logic_vector(y_trans(8 downto 7));
								att_row_num <=		std_logic_vector(y_trans(6 downto 4));
								pix_row_num <=		std_logic_vector(y_trans(3 downto 1));
								att_col_num <=		std_logic_vector(x_trans(8 downto 4));
								pix_col_num <=		std_logic_vector(x_trans(3 downto 1));
			
			when others =>	group_num <= 		std_logic_vector(y_trans(9 downto 8));
								att_row_num <=		std_logic_vector(y_trans(7 downto 5));
								pix_row_num <=		std_logic_vector(y_trans(4 downto 2));
								att_col_num <=		std_logic_vector(x_trans(9 downto 5));
								pix_col_num <=		std_logic_vector(x_trans(4 downto 2));
								
		end case;
	end process;


	-- calculates address to read data from RAM for the next pixel being rendered
	curr_pixel_addr <= group_num & pix_row_num & att_row_num & att_col_num;
	PIXEL_ADDR <= curr_pixel_addr;
		
	curr_color_addr <= group_num & att_row_num & att_col_num;
	COLOR_ADDR <= curr_color_addr;
	
	pixel_info <= PIXEL_DATA;
	color_info <= COLOR_DATA;
	
	BRIGHT <= color_info(6);
	READ_E <= read_enable or read_next;
	
	-- Read enable operation
	process (pix_col_num, RESET)
	begin
		if (RESET = '1') then
			read_enable <= '0';
		else
			if (pix_col_num = "000") then
				read_enable <= '1';
			else
				read_enable <= '0';
			end if;
		end if;
	end process;
	
	-- Read enable in advance, when display is disabled (syncing)
	process(PIXEL_CLK, DISPLAY_E, RESET)
	begin
		if (rising_edge(PIXEL_CLK)) then
			if (RESET = '1') then
				read_next <= '0';
				next_was_read <= '0';
			else
				-- read enabled for the next block when display is off and the data hasn't been read yet
				if (DISPLAY_E='0' and read_next = '0' and next_was_read = '0') then
					read_next <= '1';
					
				-- when the display turns back on, reset the state for the next sync time
				elsif (DISPLAY_E='1') then
					next_was_read <= '0';
					read_next <= '0';
					
				-- confirm that the next has been read
				else
					read_next <= '0';
					next_was_read <= '1';
				end if;
			end if;
		end if;
	end process;
		
	-- updates the color info
	process(PIXEL_CLK, RESET) is
	begin
		if (rising_edge(PIXEL_CLK)) then
			if (RESET = '1') then
				R <= '0';
				G <= '0';
				B <= '0';
			else
					-- decides what color to paint (in pixel_clock rising edge)
					--              7 6 5 4 3 2 1 0
					-- pixel_info = P P P P P P P P
					--
					--              7 6 5 4 3 2 1 0
					-- color_info = F B p p p i i i
					--		P = position (0 = paper, 1 = ink)
					-- 	F = flash
					-- 	B = bright
					-- 	p = paper color
					-- 	i = ink color
					
					-- checking if flashing is non existant or in the normal state
					if (color_info(7) = '0' or FLASH_CLK ='0') then
						-- checking if the current pixel is paper
						if (
								pixel_info(
--										(ATT_SIZE-1)-to_integer(unsigned(x_trans(ATT_COL_OFFSET-1 downto PIXEL_COL_OFFSET)))
										(ATT_SIZE-1)-to_integer(unsigned(pix_col_num))
										) = '0'
							) then
							R <= color_info(4);
							G <= color_info(5);
							B <= color_info(3);
						
						-- if it is ink
						else
							R <= color_info(1);
							G <= color_info(2);
							B <= color_info(0);
						end if;
					
					-- the opposite color is flashing
					else
						-- checking if the current pixel is paper
						if (
								pixel_info(
										(ATT_SIZE-1)-to_integer(unsigned(pix_col_num))
										) = '0'
							) then
							R <= color_info(1);
							G <= color_info(2);
							B <= color_info(0);
						
						-- if it is ink
						else
							R <= color_info(4);
							G <= color_info(5);
							B <= color_info(3);
						end if;
					end if;
			end if;
		end if;
	end process;
	
end Behavior;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;

entity data_interpreter_remaster is
	generic (
		PIXEL_MULTIPLIER : integer := 4;					-- number of real pixels per side of a ZX Spectrum pixel (4 -> 1 pixel is a square of 16)
		PIXEL_MULTIPLIER_SIZE : integer := 2;
		COUNTER_CONSTANTS_SIZE : integer := 16;
		
		ATT_SIZE : integer := 8);
		
	port(
		MEM_CLK, PIXEL_CLK, FLASH_CLK, DISPLAY_E: IN   STD_LOGIC;
		POS_DATA, COL_DATA : in std_logic_vector(7 downto 0);
		POS_ADDR, COL_ADDR : out std_logic_vector(12 downto 0);
		READ_E : out std_logic;
		R, G, B : OUT STD_LOGIC_VECTOR(1 downto 0));
end data_interpreter_remaster;

architecture Behavior of data_interpreter_remaster is

	constant COUNTER_SIZE : integer := COUNTER_CONSTANTS_SIZE + PIXEL_MULTIPLIER_SIZE*2;
	constant PIXEL_COL_OFFSET : integer := PIXEL_MULTIPLIER_SIZE;
	constant ATT_COL_OFFSET : integer := PIXEL_COL_OFFSET + 3;
	constant CTR_Y_OFFSET : integer := ATT_COL_OFFSET + 5;
	constant PIXEL_ROW_OFFSET : integer := CTR_Y_OFFSET + PIXEL_MULTIPLIER_SIZE;
	constant ATT_ROW_OFFSET : integer := PIXEL_ROW_OFFSET + 3;
	constant GROUP_OFFSET : integer := ATT_ROW_OFFSET + 3;

	-- For PIXEL_MULTIPLIER = 4
	-- F   E   D   C   B  A  9  8        7  6  5  4  3  2  1  0
	-- 13  12  11  10  F  E  D  C  B  A  9  8  7  6  5  4  3  2  1  0
	-- |____| |________| |_______||____||_____________||_______||____|
	-- group   att_row    pix_row  ctr_y    att_col    pixel_col ctr_x
	
	signal counter : std_logic_vector(COUNTER_SIZE-1 downto 0);
	constant all_ones : std_logic_vector(GROUP_OFFSET-1 downto 0) := (others => '1');

	signal pos_info, color_info : std_logic_vector(ATT_SIZE-1 downto 0);
begin

	-- calculates address to read data from RAM for the next pixel being rendered
	POS_ADDR <= counter(COUNTER_SIZE-1 downto GROUP_OFFSET) & 			-- current attribute group in a screen TIMES 2048
					counter(ATT_ROW_OFFSET-1 downto PIXEL_ROW_OFFSET) & 	-- current pixel row in an attribute block row TIMES 256
					counter(GROUP_OFFSET-1 downto ATT_ROW_OFFSET) & 		-- current attribute block row in an attribute group TIMES 32
					counter(CTR_Y_OFFSET-1 downto ATT_COL_OFFSET); 			-- current attribute block in an attribute block row
		
	COL_ADDR <= "000" & 
					counter(COUNTER_SIZE-1 downto GROUP_OFFSET) &			-- current attribute group in a screen TIMES 256
					counter(GROUP_OFFSET-1 downto ATT_ROW_OFFSET) &			-- current attribute block row in an attribute group TIMES 32
					counter(CTR_Y_OFFSET-1 downto ATT_COL_OFFSET); 			-- current attribute block in an attribute block row
	
	
	pos_info <= POS_DATA;
	color_info <= COL_DATA;
	
	-- updates the counter keeping track of the location being rendered, 
	-- in time with the VGA clock
	process(DISPLAY_E, PIXEL_CLK) is
	begin
		-- NECESSARY rising edge FOR SYNCHRONOUS ADDITIONS
		if (rising_edge(PIXEL_CLK)) then
			if (DISPLAY_E = '1') then
			
				-- READ RAM every time in the beginning of an attribute block
				-- TODO ACTUALLY TEST THIS
				if (counter(ATT_COL_OFFSET-1 downto PIXEL_COL_OFFSET) = "000") then
					READ_E <= '1';
				else
					READ_E <= '0';
				end if;
				
				-- RESET counter right before group number becomes 3
				if ((counter(COUNTER_SIZE-1 downto GROUP_OFFSET) = "10") AND (counter(GROUP_OFFSET-1 downto 0) = all_ones)) then
					counter(COUNTER_SIZE-1 downto 0) <= (others => '0');
				else
					counter <= std_logic_vector(unsigned(counter) + 1);
				end if;
			
			
				-- decides what color to paint (in pixel_clock rising edge)
				--            7 6 5 4 3 2 1 0
				-- pos_info = P P P P P P P P
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
							pos_info(
									(ATT_SIZE-1)-to_integer(unsigned(counter(ATT_COL_OFFSET-1 downto PIXEL_COL_OFFSET)))
									) = '0'
						) then
						R <= color_info(6) & color_info(4);
						G <= color_info(6) & color_info(5);
						B <= color_info(6) & color_info(3);
					
					-- if it is ink
					else
						R <= color_info(6) & color_info(1);
						G <= color_info(6) & color_info(2);
						B <= color_info(6) & color_info(0);
					end if;
				
				-- the opposite color is flashing
				else
					-- checking if the current pixel is paper
					if (
							pos_info(
									(ATT_SIZE-1)-to_integer(unsigned(counter(ATT_COL_OFFSET-1 downto PIXEL_COL_OFFSET)))
									) = '0'
						) then
						R <= color_info(6) & color_info(1);
						G <= color_info(6) & color_info(2);
						B <= color_info(6) & color_info(0);
					
					-- if it is ink
					else
						R <= color_info(6) & color_info(4);
						G <= color_info(6) & color_info(5);
						B <= color_info(6) & color_info(3);
					end if;
				end if;
			
			-- IF display is disabled
			else
				R <= "00";
				G <= "00";
				B <= "00";
			end if;
			
		end if;
	end process;
	
end Behavior;

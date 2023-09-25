library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_interpreter is
	generic (
		MULTIPLIER : integer := 4;							-- number of real pixels per side of a ZX Spectrum pixel (4 -> 1 pixel is a square of 16)
		ATT_SIZE : integer := 8;							-- number of default pixels per attribute block
		ATT_ROW_SIZE : integer := 32;						-- number of attribute blocks in a row
		ATT_ROWS_PER_GROUP : integer := 8;				-- number of attribute block rows in an attribute block group
		ATT_ROW_GROUPS : integer := 3);					-- number of attribute block row groups in a full screen
	port(
		MEM_CLK, PIXEL_CLK, FLASH_CLK, DISPLAY_E, RESET: IN   STD_LOGIC;
		POS_DATA, COL_DATA : in std_logic_vector(7 downto 0);
		POS_ADDR, COL_ADDR : out std_logic_vector(12 downto 0);
		READ_E : out std_logic;
		R, G, B : OUT STD_LOGIC_VECTOR(1 downto 0));
end data_interpreter;


architecture Behavior of data_interpreter is
	-- used to keep track of screen position in order to later calculate the correct address
	-- ctr_x starting at 1 so that the address calculated is the correct one in time for the VGA clock
	signal ctr_x : integer range 0 to MULTIPLIER-1 := 1;						-- current real pixel column in a ZX Spectrum pixel
	signal curr_pixel_column : integer range 0 to ATT_SIZE-1 := 0;			-- current column (ZX Spectrum pixel) in an attribute block's row
	signal curr_att_column : integer range 0 to ATT_ROW_SIZE-1 := 0;		-- current attribute block in a row of attribute blocks
	signal ctr_y : integer range 0 to MULTIPLIER-1 := 0;						-- current real pixel row in a full ZX Spectrum pixel row
	signal curr_pixel_row : integer range 0 to ATT_SIZE-1 := 0;				-- current row of Spectrum pixels in a full attribute block row
	signal curr_att_row : integer range 0 to ATT_ROWS_PER_GROUP-1 := 0;	-- current attribute block row in an attribute block row group
	signal curr_att_row_group : integer range 0 to ATT_ROW_GROUPS-1 := 0;-- current group of attribute block rows
	
	-- hold screen and color data of what attribute block is being rendered at the moment
	signal pos_info, color_info : std_logic_vector(7 downto 0);
	
	signal first_read : std_logic := '1';
		
begin
	-- calculates address to read data from RAM for the next pixel being rendered
	POS_ADDR <= std_logic_vector(to_unsigned(curr_att_column + (curr_pixel_row*256) + (curr_att_row*32) + (curr_att_row_group*2048), POS_ADDR'length));				
	
	COL_ADDR <= std_logic_vector(to_unsigned(curr_att_column + (curr_att_row*32) + (curr_att_row_group*256), COL_ADDR'length));
	
	pos_info <= POS_DATA;
	color_info <= COL_DATA;
	
	
	-- updates the current numbers of each position related variable, keeping track of the location being rendered, 
	-- in time with the VGA clock
	process(RESET, DISPLAY_E, PIXEL_CLK) is
	begin
		if (RESET = '1') then
			ctr_x <= 0;
			curr_pixel_column <= 0;
			curr_att_column <= 0;
			ctr_y <= 0;
			curr_pixel_row <= 0;
			curr_att_row <= 0;
			curr_att_row_group <= 0;
			READ_E <= '0';
			
			R <= "00";
			G <= "00";
			B <= "00";
		-- NECESSARY rising edge FOR SYNCHRONOUS ADDITIONS
		elsif (rising_edge(PIXEL_CLK)) then
			if (DISPLAY_E = '1') then
			
				if (first_read = '1') then
					READ_E <= '1';
					first_read <= '0';
				end if;
				-- increments with every pixel, resetting after every ZX Specturm pixel
				if (ctr_x < MULTIPLIER-1) then
					ctr_x <= ctr_x+1;
				else

					ctr_x <= 0;
					-- increments with every ZX Spectrum pixel in an attribute block, resetting after every attribute block (horizontally)
					if (curr_pixel_column < ATT_SIZE-1) then
						READ_E <= '0';
						curr_pixel_column <= curr_pixel_column + 1;
						
					else
						curr_pixel_column <= 0;
						READ_E <= '1';
						
						-- increments with every attribute block in the row, resetting after every new row of pixels
						if (curr_att_column < ATT_ROW_SIZE-1) then
							curr_att_column <= curr_att_column + 1;
							--READ_E <= '1';
						else
							curr_att_column <= 0;
							--READ_E <= '1';
							
							-- increments with every row of pixels, resetting after a row of ZX Spectrum pixels is drawn
							if (ctr_y < MULTIPLIER-1) then
								ctr_y <= ctr_y+1;
							else
								ctr_y <= 0;
								
								-- increments with every row of Spectrum pixels, resetting after every attribute block (vertically)
								if (curr_pixel_row < ATT_SIZE-1) then
									curr_pixel_row <= curr_pixel_row + 1;
								else
									curr_pixel_row <= 0;
									
									-- increments with every different row of attribute blocks, resetting after every group of attributes
									if (curr_att_row < ATT_ROWS_PER_GROUP-1) then
										curr_att_row <= curr_att_row + 1;
									else
										curr_att_row <= 0;
										
										-- increments with every different group of rows, resetting after reaching the end of the screen
										if (curr_att_row_group < ATT_ROW_GROUPS-1) then
											curr_att_row_group <= curr_att_row_group + 1;
										else
											curr_att_row_group <= 0;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;
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
				if (pos_info((ATT_SIZE-1)-curr_pixel_column) = '0') then
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
				if (pos_info((ATT_SIZE-1)-curr_pixel_column) = '0') then
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

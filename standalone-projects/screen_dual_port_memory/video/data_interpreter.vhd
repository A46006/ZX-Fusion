library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_interpreter is
	generic (
		SCREEN_MEM_OFFSET :  integer := 0; --std_logic_vector(12 downto 0) := (others => '0');
		SCREEN_COLOR_OFFSET : integer := 6144; --std_logic_vector(12 downto 0) := "11" & (others => 0); -- 0x1800
	
		MULTIPLIER : integer := 4;							-- number of real pixels per side of a ZX Spectrum pixel (4 -> 1 pixel is a square of 16)
		ATT_SIZE : integer := 8;							-- number of default pixels per attribute block
		ATT_ROW_SIZE : integer := 32;						-- number of attribute blocks in a row
		ATT_ROWS_PER_GROUP : integer := 8;				-- number of attribute block rows in an attribute block group
		ATT_ROW_GROUPS : integer := 3);					-- number of attribute block row groups in a full screen
	port(
		MEM_CLK, PIXEL_CLK, DISPLAY_E: IN   STD_LOGIC;
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
	
	
	-- keeps state of current color in flash attributes
	-- 0: normal, 1: reverse ink and paper
	signal flash_state : std_logic := '0';
	signal flash_ctr : integer range 0 to 16250000 := 0; -- 65M/4
	
	signal read_time : std_logic := '1';
		
begin
	-- calculates address to read data from RAM for the next pixel being rendered
	POS_ADDR <= std_logic_vector(to_unsigned(curr_att_column + (curr_pixel_row*256) + (curr_att_row*32) + (curr_att_row_group*2048), POS_ADDR'length));				
	
	COL_ADDR <= std_logic_vector(to_unsigned(curr_att_column + (curr_att_row*32) + (curr_att_row_group*256), COL_ADDR'length));
	
	
	
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
													-- flash state normal or no flashing, paper color
	-- used to fetch data from RAM quicker than VGA can render (clk rising edge, instead of pixel_clk)
	-- reads the data related	to the attribute block VGA is currently rendering in
	-- HOPEFULLY gets data in interval before VGA renders
	process(MEM_CLK, DISPLAY_E) is
	begin
		
		if (rising_edge(MEM_CLK)) then
			if (DISPLAY_E = '0') then
				R <= "00";
				G <= "00";
				B <= "00";
			else
				if (read_time = '1') then
					READ_E <= '1';
					pos_info <= POS_DATA;
					color_info <= COL_DATA;
				else
					READ_E <= '0';
				end if;
				
				-- checking if flashing is non existant or in the normal state
				if (color_info(7) = '0' or flash_state ='0') then
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
			end if;
		end if;
	end process;
	
	
	
	-- updates the current numbers of each position related variable, keeping track of the location being rendered, 
	-- in time with the VGA clock
	process(DISPLAY_E, PIXEL_CLK) is
	begin
		
		
		-- NECESSARY rising edge FOR SYNCHRONOUS ADDITIONS
		if (rising_edge(PIXEL_CLK)) then
			if (DISPLAY_E = '1') then
				-- increments with every pixel, resetting after every ZX Specturm pixel
				if (ctr_x < MULTIPLIER-1) then
					ctr_x <= ctr_x+1;
				else

					ctr_x <= 0;
					-- increments with every ZX Spectrum pixel in an attribute block, resetting after every attribute block (horizontally)
					if (curr_pixel_column < ATT_SIZE-1) then
						read_time <= '0';
						curr_pixel_column <= curr_pixel_column + 1;
						
						if (curr_pixel_column = ATT_SIZE-2) then
							-- Tell the other process to read, now that the counters for the address are set for this moment
							read_time <= '1';
						end if;
					else
						curr_pixel_column <= 0;
						
						-- increments with every attribute block in the row, resetting after every new row of pixels
						if (curr_att_column < ATT_ROW_SIZE-1) then
							curr_att_column <= curr_att_column + 1;
							--read_time <= '1';
						else
							curr_att_column <= 0;
							--read_time <= '1';
							
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
				
				if (flash_ctr < 16249999) then
					flash_ctr <= flash_ctr + 1;
				else
					flash_ctr <= 0;
					flash_state <= not flash_state;
				end if;
				
				-- COLOR CHECK, SYNCHRONIZED:
				
				
			end if;
		end if;
	end process;
	
	
end Behavior;
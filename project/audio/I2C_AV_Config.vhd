-- From Terasic DE2_115_Default project in SystemCD
-- Translated to VHDL
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2C_AV_Config is 
	generic (
		-- Clock Setting
		CLK_Freq    : integer := 50000000;
		I2C_Freq    : integer := 20000;
		-- LUT Data Number
		LUT_SIZE    : integer := 51;
		-- Audio Data Index
		Dummy_DATA  : integer := 0;
		SET_LIN_L   : integer := 1;
		SET_LIN_R   : integer := 2;
		SET_HEAD_L  : integer := 3;
		SET_HEAD_R  : integer := 4;
		A_PATH_CTRL : integer := 5;
		D_PATH_CTRL : integer := 6;
		POWER_ON    : integer := 7;
		SET_FORMAT  : integer := 8;
		SAMPLE_CTRL : integer := 9;
		SET_ACTIVE  : integer := 10;
		-- Video Data Index
		SET_VIDEO   : integer := 11
	);
	port (
		-- Host Side
		CLK      : in    std_logic;
		RST_N    : in    std_logic;
		
		-- I2C Side
		I2C_SCLK : out   std_logic;
		I2C_SDAT : inout std_logic
	);
end I2C_AV_Config;

architecture Behavior of I2C_AV_Config is
	component I2C_Controller is 
		port (
			CLOCK    : in    std_logic;
			I2C_DATA : in    std_logic_vector(23 downto 0);
			GO_t     : in    std_logic;
			RESET_n  : in    std_logic;
			I2C_SDAT : inout std_logic;
			I2C_SCLK : out   std_logic;
			END_t    : out   std_logic;
			ACK      : out   std_logic
			
		);
	end component;

	signal mI2C_CLK_DIV  : unsigned(15 downto 0);
	signal mI2C_DATA     : std_logic_vector(23 downto 0);
	signal mI2C_CTRL_CLK : std_logic;
	signal mI2C_GO       : std_logic;
	signal mI2C_END      : std_logic;
	signal mI2C_ACK      : std_logic;
	signal LUT_DATA      : std_logic_vector(15 downto 0);
	signal LUT_INDEX     : integer range 0 to 63 := 0; --std_logic_vector(5 downto 0);
	signal mSetup_ST     : std_logic_vector(3 downto 0);
begin
	
	-- /////////////////////	I2C Control Clock	////////////////////////
	process(CLK, RST_N)
	begin
		if(rising_edge(CLK)) then
			if (RST_N = '0') then
				mI2C_CTRL_CLK  <= '0';
				mI2C_CLK_DIV	<=	(others => '0');
			else
				if (mI2C_CLK_DIV < to_unsigned(CLK_Freq/I2C_Freq, mI2C_CLK_DIV'length)) then
					mI2C_CLK_DIV <= mI2C_CLK_DIV + 1;
				else
					mI2C_CLK_DIV <= (others => '0');
					mI2C_CTRL_CLK <= not mI2C_CTRL_CLK;
					
				end if;
			end if;
		end if;
	end process;

	-- ////////////////////////////////////////////////////////////////////
	i2c_con : I2C_Controller port map (
				CLOCK    => mI2C_CTRL_CLK,
				I2C_DATA => mI2C_DATA,
				GO_t     => mI2C_GO,
				RESET_n  => RST_N,
				--W_R      => ...
				I2C_SDAT => I2C_SDAT,
				I2C_SCLK => I2C_SCLK,
				END_t    => mI2C_END,
				ACK      => mI2C_ACK
		);
	
	-- ////////////////////////////////////////////////////////////////////
	-- //////////////////////	Config Control	////////////////////////////
	process(mI2C_CTRL_CLK, RST_N)
	begin
		if(rising_edge(mI2C_CTRL_CLK)) then
			if (RST_N = '0') then
				LUT_INDEX	<=	0;
				mSetup_ST	<=	(others => '0');
				mI2C_GO		<=	'0';
			else
				if (LUT_INDEX<LUT_SIZE) then
					case mSetup_ST is
						when "0000" => if (LUT_INDEX<SET_VIDEO) then
												mI2C_DATA <= x"34" & LUT_DATA;
											else
												mI2C_DATA <= x"40" & LUT_DATA;
												mI2C_GO   <= '1';
												mSetup_ST <= "0001";
											end if;
											
						when "0001" => if (mI2C_END = '1') then
												if (mI2C_ACK = '0') then
													mSetup_ST <= "0010";
												else
													mSetup_ST <= (others => '0');
													mI2C_GO   <= '0';
												end if;
											end if;
											
						when "0010" => LUT_INDEX	<=	LUT_INDEX + 1;
											mSetup_ST	<=	(others => '0');
						
						when others => null;
					end case;
				else
					
					
				end if;
			end if;
		end if;
	end process;
	
	-- ////////////////////////////////////////////////////////////////////
	-- /////////////////////	Config Data LUT	  //////////////////////////	
	LUT_DATA <= x"001A" when LUT_INDEX = SET_LIN_L else
					x"021A" when LUT_INDEX = SET_LIN_L else
					x"047B" when LUT_INDEX = SET_HEAD_L else
					x"067B" when LUT_INDEX = SET_HEAD_R else
					x"08F8" when LUT_INDEX = A_PATH_CTRL else
					x"0A06" when LUT_INDEX = D_PATH_CTRL else
					x"0C00" when LUT_INDEX = POWER_ON else
					x"0E01" when LUT_INDEX = SET_FORMAT else
					x"1002" when LUT_INDEX = SAMPLE_CTRL else
					x"1201" when LUT_INDEX = SET_ACTIVE else
					x"0000";

end Behavior;
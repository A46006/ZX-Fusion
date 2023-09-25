library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity input_receiver is
	port(
		ADDRESS, PS2_SCAN_CODE : in std_logic_vector(7 downto 0); -- A15 to A8
		VALID : in std_logic;
		NATIVE_DATA : in std_logic_vector(4 downto 0);
		PS2nNat : in std_logic;
		KEY_DATA : out std_logic_vector(4 downto 0)
	);
end input_receiver;

architecture Behavior of input_receiver is
	--component ps2_intf is
	--	port(
	--	CLK			:	in	std_logic;
	--	nRESET		:	in	std_logic;
	--	
	--	-- PS/2 interface (could be bi-dir)
	--	PS2_CLK		:	in	std_logic;
	--	PS2_DATA	:	in	std_logic;
	--	
	--	-- Byte-wide data interface - only valid for one clock
	--	-- so must be latched externally if required
	--	DATA		:	out	std_logic_vector(7 downto 0);
	--	VALID		:	out	std_logic;
	--	ERROR		:	out	std_logic
	--	);
	--end component;

	signal PS2_converted_data, 
		half_row_0_o, half_row_1_o, half_row_2_o, half_row_3_o, 
		half_row_4_o, half_row_5_o, half_row_6_o, half_row_7_o : std_logic_vector(4 downto 0);
		
	
	signal  half_row_0, half_row_1, half_row_2, half_row_3, 
		half_row_4, half_row_5, half_row_6, half_row_7 : std_logic_vector(4 downto 0) := "11111";
		
	signal release : std_logic;
begin
	KEY_DATA <= NATIVE_DATA when PS2nNat = '0' else PS2_converted_data;
	
	PS2_converted_data <= half_row_0_o AND half_row_1_o AND half_row_2_o AND half_row_3_o AND 
		half_row_4_o AND half_row_5_o AND half_row_6_o AND half_row_7_o;
	
	-- Each half-row processed seperately to support multiple half-rows being checked simultaneously
	half_row_0_o <= "11111" when ADDRESS(0) = '1' else half_row_0; -- A8
	half_row_1_o <= "11111" when ADDRESS(1) = '1' else half_row_1; -- A9
	half_row_2_o <= "11111" when ADDRESS(2) = '1' else half_row_2; -- A10
	half_row_3_o <= "11111" when ADDRESS(3) = '1' else half_row_3; -- A11
	half_row_4_o <= "11111" when ADDRESS(4) = '1' else half_row_4; -- A12
	half_row_5_o <= "11111" when ADDRESS(5) = '1' else half_row_5; -- A13
	half_row_6_o <= "11111" when ADDRESS(6) = '1' else half_row_6; -- A14
	half_row_7_o <= "11111" when ADDRESS(7) = '1' else half_row_7; -- A15
	
	process (VALID) is
	begin
		if (VALID = '1') then
			if (PS2_SCAN_CODE = x"F0") then
				release <= '1';
			else
				case(PS2_SCAN_CODE) is
					-- ADAPTED FROM MIKE STIRLING'S ZX SPECTRUM IN DE-115, keyboard.vhd
				
					when X"12" => half_row_0(0) <= release; -- Left shift (CAPS SHIFT)
					when X"59" => half_row_0(0) <= release; -- Right shift (CAPS SHIFT)
					when X"1a" => half_row_0(1) <= release; -- Z
					when X"22" => half_row_0(2) <= release; -- X
					when X"21" => half_row_0(3) <= release; -- C
					when x"2A" => half_row_0(4) <= release; -- v
					
					when X"1c" => half_row_1(0) <= release; -- A
					when X"1b" => half_row_1(1) <= release; -- S
					when X"23" => half_row_1(2) <= release; -- D
					when X"2b" => half_row_1(3) <= release; -- F
					when X"34" => half_row_1(4) <= release; -- G
					
					when X"15" => half_row_2(0) <= release; -- Q
					when X"1d" => half_row_2(1) <= release; -- W
					when X"24" => half_row_2(2) <= release; -- E
					when X"2d" => half_row_2(3) <= release; -- R
					when X"2c" => half_row_2(4) <= release; -- T				
				
					when X"16" => half_row_3(0) <= release; -- 1
					when X"1e" => half_row_3(1) <= release; -- 2
					when X"26" => half_row_3(2) <= release; -- 3
					when X"25" => half_row_3(3) <= release; -- 4
					when X"2e" => half_row_3(4) <= release; -- 5			
					
					when X"45" => half_row_4(0) <= release; -- 0
					when X"46" => half_row_4(1) <= release; -- 9
					when X"3e" => half_row_4(2) <= release; -- 8
					when X"3d" => half_row_4(3) <= release; -- 7
					when X"36" => half_row_4(4) <= release; -- 6
					
					when X"4d" => half_row_5(0) <= release; -- P
					when X"44" => half_row_5(1) <= release; -- O
					when X"43" => half_row_5(2) <= release; -- I
					when X"3c" => half_row_5(3) <= release; -- U
					when X"35" => half_row_5(4) <= release; -- Y
					
					when X"5a" => half_row_6(0) <= release; -- ENTER
					when X"4b" => half_row_6(1) <= release; -- L
					when X"42" => half_row_6(2) <= release; -- K
					when X"3b" => half_row_6(3) <= release; -- J
					when X"33" => half_row_6(4) <= release; -- H
					
					when X"29" => half_row_7(0) <= release; -- SPACE
					when X"14" => half_row_7(1) <= release; -- CTRL (Symbol Shift)
					when X"3a" => half_row_7(2) <= release; -- M
					when X"31" => half_row_7(3) <= release; -- N
					when X"32" => half_row_7(4) <= release; -- B
					
					-- Cursor keys - these are actually extended (E0 xx), but
					-- the scancodes for the numeric keypad cursor keys are
					-- are the same but without the extension, so we'll accept
					-- the codes whether they are extended or not
					when X"6B" => 	half_row_0(0) <= release; -- Left (CAPS 5)
										half_row_3(4) <= release;
					when X"72" =>	half_row_0(0) <= release; -- Down (CAPS 6)
										half_row_4(4) <= release;
					when X"75" =>	half_row_0(0) <= release; -- Up (CAPS 7)
										half_row_4(3) <= release;
					when X"74" =>	half_row_0(0) <= release; -- Right (CAPS 8)
										half_row_4(2) <= release;
									
					-- Other special keys sent to the ULA as key combinations
					when X"66" =>	half_row_0(0) <= release; -- Backspace (CAPS 0)
										half_row_4(0) <= release;
					when X"58" =>	half_row_0(0) <= release; -- Caps lock (CAPS 2)
										half_row_3(1) <= release;
					when X"76" =>	half_row_0(0) <= release; -- Escape (CAPS SPACE)
										half_row_7(0) <= release;
					
					when others =>
						null;
						
				end case;
				release <= '0';
			end if;
		end if;
		
		--if (ADDRESS(0) = '0') then -- A8
		--	
		--end;
	end process;
	
end Behavior;

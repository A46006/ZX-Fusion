LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;

ENTITY

ENTITY spin_anim_7seg IS
	PORT ( 
			CLK : IN STD_LOGIC;
			SET : IN STD_LOGIC;
			CLR : IN STD_LOGIC;
			D : OUT STD_LOGIC_VECTOR(0 TO 6)
			);
END spin_anim_7seg;

ARCHITECTURE Behavior OF spin_anim_7seg IS
	signal state : integer range 0 to 7 := 0;
BEGIN
	D <=	"0000001" when state = 0 else
			"0111111" when state = 1 else
			"1011111" when state = 2 else
			"1101111" when state = 3 else
			"1110111" when state = 4 else
			"1111011" when state = 5 else
			"1111101" when state = 6 else
			"1111111" when state = 7;
	
	process(CLK)
	begin
		if (rising_edge(CLK)) then
			if (CLR = '1') then
				state <= 7;
			elsif (SET = '1') then
				state <= 0;
			else
				if (state == 0 OR state > 5) then
					state <= 1;
				else
					state <= state + 1;
				end if;
			end if;
		end if;
	end process;
	
END Behavior;


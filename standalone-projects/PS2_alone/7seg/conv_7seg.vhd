LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
USE work.symbols_7seg.all;

ENTITY conv_7seg IS
	PORT ( NUMBER : IN STD_LOGIC_VECTOR(7 downto 0);
			 NUM1, NUM0 : OUT STD_LOGIC_VECTOR(0 TO 6));
END conv_7seg;

ARCHITECTURE Behavior OF conv_7seg IS
	COMPONENT mux_16to1_7bit
		PORT ( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : IN STD_LOGIC_VECTOR(0 TO 6);
			s : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			D : OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	BEGIN
		outmux1 : mux_16to1_7bit PORT MAP (
					zero, one, two, three, four, five, six, seven, eight, nine, A, B, C, D, E, F,
					NUMBER(7 downto 4), NUM1);
		outmux0 : mux_16to1_7bit PORT MAP (
					zero, one, two, three, four, five, six, seven, eight, nine, A, B, C, D, E, F,
					NUMBER(3 downto 0), NUM0);
END Behavior;
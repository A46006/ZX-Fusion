LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.symbols_7seg.all; -- used for others case, for "empty"

ENTITY mux_16to1_7bit IS
	PORT ( a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15 : IN STD_LOGIC_VECTOR(0 TO 6);
			s : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			D : OUT STD_LOGIC_VECTOR(0 TO 6));
END mux_16to1_7bit;

ARCHITECTURE Behavior OF mux_16to1_7bit IS
BEGIN
	PROCESS (a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, s) IS
	BEGIN
		CASE s IS
			WHEN x"0" => D <= a0;
			WHEN x"1" => D <= a1;
			WHEN x"2" => D <= a2;
			WHEN x"3" => D <= a3;
			WHEN x"4" => D <= a4;
			WHEN x"5" => D <= a5;
			WHEN x"6" => D <= a6;
			WHEN x"7" => D <= a7;
			WHEN x"8" => D <= a8;
			WHEN x"9" => D <= a9;
			WHEN x"A" => D <= a10;
			WHEN x"B" => D <= a11;
			WHEN x"C" => D <= a12;
			WHEN x"D" => D <= a13;
			WHEN x"E" => D <= a14;
			WHEN x"F" => D <= a15;
		END CASE;
	END PROCESS;
		
END Behavior;

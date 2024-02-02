library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity kempston_if is
	port(
		EN, RESET : in std_logic;
		JOY_STATE : in std_logic_vector(7 downto 0);
		DATA : out std_logic_vector(7 downto 0) := (others => '1')
	);
end kempston_if;

architecture Behavior of kempston_if is
begin

	DATA <= x"00" when RESET = '1' else JOY_STATE(1) & -- B = btn2
														'0' &
														JOY_STATE(3) & -- START = btn3
														JOY_STATE(0) & -- A = btn1 (fire)
														JOY_STATE(4) &
														JOY_STATE(5) &
														JOY_STATE(6) &
														JOY_STATE(7);
				

end Behavior;
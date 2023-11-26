library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
	port (
		CLOCK_50 : IN std_logic;
		SW : in std_logic_vector(17 downto 0);
--		KEY : in std_logic_vector(3 downto 0);
--		LEDR : out std_logic_vector(17 downto 0);
--		LEDG : out std_logic_vector(7 downto 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6)
	);
end top;

architecture Behavior of top is
	COMPONENT conv_7seg IS
		PORT ( number : IN STD_LOGIC_VECTOR(7 downto 0);
			 num1, num0 : OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;
	
	COMPONENT double_spin_anim_7seg IS
		PORT ( 
				CLOCK_50 : IN STD_LOGIC;
				SET      : IN STD_LOGIC;
				CLR      : IN STD_LOGIC;
				D3, D2, D1, D0 : OUT STD_LOGIC_VECTOR(0 TO 6)
				);
	END COMPONENT;
	
begin
	double_spin : double_spin_anim_7seg port map (
			CLOCK_50 => CLOCK_50,
			SET => SW(1),
			CLR => SW(0),
			D3 => HEX7,
			D2 => HEX6,
			D1 => HEX5,
			D0 => HEX4
	);

	HEX3 <= "1111111";
	HEX2 <= "1111111";
	HEX1 <= "1111111";
	HEX0 <= "1111111";
	
end Behavior;


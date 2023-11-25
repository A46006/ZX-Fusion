library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
	port (
		--CLOCK_50 : IN std_logic;
		SW : in std_logic_vector(17 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(7 downto 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6));
end top;

architecture Behavior of top is
	COMPONENT conv_7seg IS
		PORT ( number : IN STD_LOGIC_VECTOR(7 downto 0);
			 num1, num0 : OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;

	
	-- COUNTER RELATED
	signal count : std_logic_vector(2 downto 0); -- minimum of 3 clocks for reset
	signal reset_ctr_start : std_logic := '1';
	signal reset_ctr_manual : std_logic;
	
	signal data_view : std_logic_vector(7 downto 0);
	
begin
	address_low : conv_7seg port map (address(7 downto 0), HEX1, HEX0);
	address_high : conv_7seg port map (address(15 downto 8), HEX3, HEX2);
	data_7seg : conv_7seg port map(data_view, HEX7, HEX6);
	HEX5 <= "0001000";
	HEX4 <= "1111110";

	LEDG <= data_view;
	LEDR(15 downto 0) <= address;
	LEDR(17) <= not read_n;
	LEDR(16) <= not write_n;

	
end Behavior;


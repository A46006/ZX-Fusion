library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
	port (
		CLOCK_50 : IN std_logic;
		SW : in std_logic_vector(17 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(7 downto 0);
		PS2_CLK, PS2_DAT : in std_logic;
		
		--------- EXPANSION ---------
		KEYB_ADDR : out std_logic_vector(7 downto 0);
		KEYB_DATA : in std_logic_vector(4 downto 0);
		
		HEX0, HEX1, HEX2, HEX3 : out STD_LOGIC_VECTOR(0 to 6));
end top;

architecture Behavior of top is
	component keyboard_top is
		port(
			CLOCK, PS2_CLOCK, PS2_DATA, RESET : in std_logic;
			NATIVE_DATA : in std_logic_vector(4 downto 0);
			PS2nNat : in std_logic;
			ADDRESS : in std_logic_vector(7 downto 0);
			VALID, ERROR : out std_logic;
			KEY_DATA : out std_logic_vector(4 downto 0)
		);
	end component;
	
	component conv_7seg
		PORT ( number : IN STD_LOGIC_VECTOR(7 downto 0);
			 num1, num0 : OUT STD_LOGIC_VECTOR(0 TO 6));
	end component;
	
	signal reset, ps2_nNat : std_logic;
	signal address : std_logic_vector(15 downto 0);
	signal native_data : std_logic_vector(4 downto 0);
	
begin
	keyboard: keyboard_top port map (CLOCK_50, PS2_CLK, PS2_DAT, reset, native_data, ps2_nNat, address(15 downto 8), LEDR(17), LEDR(16), LEDG(4 downto 0));
	conv_7seg_1 : conv_7seg port map (address(15 downto 8), HEX3, HEX2);
	conv_7seg_0 : conv_7seg port map (address(7 downto 0), HEX1, HEX0);
	
	--LEDR(9 downto 5) <= "01111" and "10111";
	
	address(7 downto 0) <= x"FE";
	address(15 downto 8) <= SW(7 downto 0);
	
	native_data <= KEYB_DATA;
	KEYB_ADDR <= address(15 downto 8);
	
	LEDR(4 downto 0) <= KEYB_DATA;
	
	reset <= SW(17);
	ps2_nNat <= SW(16);
end architecture;

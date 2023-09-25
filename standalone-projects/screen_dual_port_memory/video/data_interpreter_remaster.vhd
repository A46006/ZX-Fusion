library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity data_interpreter_remaster is
	generic (
		MULTIPLIER : integer := 4);							-- number of real pixels per side of a ZX Spectrum pixel (4 -> 1 pixel is a square of 16)
	port(
		MEM_CLK, DISPLAY_E: IN   STD_LOGIC;
		X, Y : in integer;
		POS_DATA, COL_DATA : in std_logic_vector(7 downto 0);
		POS_ADDR, COL_ADDR : out std_logic_vector(12 downto 0);
		READ_E : out std_logic;
		R, G, B : OUT STD_LOGIC_VECTOR(1 downto 0));
end data_interpreter_remaster;

architecture Behavior of data_interpreter_remaster is
	
begin
	process(MEM_CLK) is
	begin
		if (rising_edge(MEM_CLK)) then
			if (DISPLAY_E = '1') then
				
			end if;
		end if;
	end process;
end Behavior;
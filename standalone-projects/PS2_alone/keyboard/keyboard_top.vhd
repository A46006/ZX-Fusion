library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyboard_top is
	port(
		CLOCK, PS2_CLOCK, PS2_DATA, RESET : in std_logic;
		NATIVE_DATA : in std_logic_vector(4 downto 0);
		PS2nNat : in std_logic;
		ADDRESS : in std_logic_vector(7 downto 0);
		VALID, ERROR : out std_logic;
		KEY_DATA : out std_logic_vector(4 downto 0)
	);
end keyboard_top;

architecture Behavior of keyboard_top is
	component ps2_intf is
		port(
			CLK			:	in	std_logic;
			nRESET		:	in	std_logic;
			
			-- PS/2 interface
			PS2_CLK		:	in	std_logic;
			PS2_DATA	:	in	std_logic;
			
			-- Byte-wide data interface
			DATA		:	out	std_logic_vector(7 downto 0);
			VALID		:	out	std_logic;
			ERROR		:	out	std_logic
		);
	end component;
	
	component input_receiver is
		port(
			ADDRESS, PS2_SCAN_CODE : in std_logic_vector(7 downto 0); -- A15 to A8
			VALID : in std_logic;
			NATIVE_DATA : in std_logic_vector(4 downto 0);
			PS2nNat : in std_logic;
			KEY_DATA : out std_logic_vector(4 downto 0)
		);
	end component;
		
	signal ps2_scan_code : std_logic_vector(7 downto 0);
	signal key_valid, key_error : std_logic;
		
begin
	ps2_controller : ps2_intf port map (CLOCK, not RESET, PS2_CLOCK, PS2_DATA, ps2_scan_code, key_valid, key_error);
	input_rcvr : input_receiver port map(ADDRESS, ps2_scan_code, key_valid, NATIVE_DATA, PS2nNat, KEY_DATA);
	VALID <= key_valid;
	ERROR <= key_error;
end Behavior;
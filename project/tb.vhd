library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.constants.native_n_ps2;
use work.constants.video_mode;

entity tb is
end tb;

architecture tb_arch of tb is
	component top is
		port (			
			CLOCK_50 : IN std_logic;
			------------ VGA -------------
			VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK : out STD_LOGIC;
			VGA_R, VGA_G, VGA_B : out STD_LOGIC_VECTOR(7 downto 0);
			
			------------ PS2 -------------
			PS2_CLK, PS2_DAT : inout std_logic;
			
			------------- SD -------------
			SD_CLK : out std_logic;
			SD_CMD : inout std_logic;
			SD_DAT : inout std_logic_vector(3 downto 0);
			SD_WP_N : in std_logic;
			
			----------- BOARD ------------
			SW : in std_logic_vector(17 downto 0);
			KEY : in std_logic_vector(3 downto 0);
			LEDR : out std_logic_vector(17 downto 0) := (others => '0');
			LEDG : out std_logic_vector(7 downto 0) := (others => '0')
		);
	end component;

	-------------
	-- SIGNALS --
	-------------
	-- TB --
	signal clock_50 : std_logic := '0';
	signal clk_50 : std_logic;
	signal reset : std_logic;
	
	signal VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK : std_logic;
	signal VGA_R, VGA_G, VGA_B : std_logic_vector(7 downto 0);
	
	signal SD_CLK, SD_CMD, SD_WP_N : std_logic := '1';
	signal SD_DAT : std_logic_vector(3 downto 0);
	
	signal SW : std_logic_vector(17 downto 0);
	signal KEY : std_logic_vector(3 downto 0);
	signal LEDR : std_logic_vector(17 downto 0);
	signal LEDG : std_logic_vector(7 downto 0);
	
	signal PS2_CLOCK, PS2_DAT : std_logic := '0';
	signal PS2_CLK : std_logic;
begin
	clock_50 <= not clock_50 after 10 ns; -- t=10ns => T=20ns => f=1/20ns = 50 MHz
	clk_50 <= clock_50;
	
	KEY(0) <= not reset;
	
	SW(1 downto 0) <= video_mode;
	SW(17) <= native_n_ps2;
	
	PS2_CLOCK <= not PS2_CLOCK after 50 us; -- t=50us => T=100us => f=1/100us = 10KHz
	PS2_CLK <= PS2_CLOCK;
	
	uut : top port map (
		CLOCK_50 => clk_50,
		
		VGA_HS => VGA_HS,
		VGA_VS => VGA_VS,
		VGA_BLANK_N => VGA_BLANK_N,
		VGA_SYNC_N => VGA_SYNC_N,
		VGA_CLK => VGA_CLK,
		VGA_R => VGA_R, VGA_G => VGA_G, VGA_B => VGA_B,
		
		SD_CLK => SD_CLK,
		SD_CMD => SD_CMD,
		SD_DAT => SD_DAT,
		SD_WP_N => SD_WP_N,
		
		PS2_CLK => PS2_CLK,
		PS2_DAT => PS2_DAT,
		
		SW => SW, KEY => KEY, LEDR => LEDR, LEDG => LEDG

	);
	
	-- tb process --
	tb : process
	begin
		wait for 5 ns;
	
		reset <= '1' after 0 ns, '0' after 101 ns;
		
		wait for 50 ms;
		assert false report "fim da simulação!" severity warning;
		wait; -- will wait forever
	end process;
end tb_arch;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;

entity tb is
end tb;

architecture tb_arch of tb is
	component top is
		port (			
			CLOCK_50 : IN std_logic;
			SW : in std_logic_vector(17 downto 0);
			KEY : in std_logic_vector(3 downto 0);
			LEDR : out std_logic_vector(17 downto 0);
			LEDG : out std_logic_vector(7 downto 0);
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6)
		);
	end component;

	-------------
	-- SIGNALS --
	-------------
	-- TB --
	signal clock_50 : std_logic := '0';
	signal clk_50 : std_logic;
	signal clock_3_5 : std_logic := '0';
	signal clk_3_5 : std_logic;
	signal reset : std_logic;
	
	signal SW : std_logic_vector(17 downto 0);
	signal KEY : std_logic_vector(3 downto 0);
	signal LEDR : std_logic_vector(17 downto 0);
	signal LEDG : std_logic_vector(7 downto 0);
	
	signal hex0, hex1, hex2, hex3, hex4, hex5, hex6, hex7 : std_logic_vector(0 to 6);
	
	signal bus_rq : std_logic := '0';
	signal busak : std_logic := '0';
	signal nmi : std_logic := '0';
	signal int : std_logic := '0';
	
	signal halt : std_logic := '0';
	
begin
	clock_50 <= not clock_50 after 10 ns; -- t=10ns => T=20ns => f=1/20ns = 50 MHz
	clock_3_5 <= not clock_3_5 after 142.8571428 ns; -- t= 143 ns => T=286 => f=1/286ns =  3,49 MHz
	clk_50 <= clock_50;
	clk_3_5 <= clock_3_5;
	
	KEY(0) <= clk_3_5; 	-- the T80's clock
	KEY(1) <= not reset;	-- reset
	SW(17) <= bus_rq;
	SW(16) <= nmi;
	SW(15) <= int;
	
	busak <= LEDG(0);
	halt <= LEDG(1);
	
	--SW(1 downto 0) <= video_mode;
	--SW(17) <= native_n_ps2;
	
	
	uut : top port map (
		CLOCK_50 => clk_50,
		SW => SW, 
		KEY => KEY, 
		LEDR => LEDR, 
		LEDG => LEDG,
		HEX0 => hex0, 
		HEX1 => hex1,
		HEX2 => hex2,
		HEX3 => hex3,
		HEX4 => hex4,
		HEX5 => hex5,
		HEX6 => hex6,
		HEX7 => hex7

	);
	
	-- tb process --
	tb : process
	begin
		wait for 5 ns;
	
		reset <= '1' after 0 ns, '0' after 200 ns;
		
		wait until reset = '0' and halt = '1';
		
		--wait until halt = '1';
		wait for 500 ns;
		
		bus_rq <= '1';
		wait on busak;
		
		nmi <= '1';
		
		wait for 500 ns;
		bus_rq <= '0';
		wait on busak;
		
		wait for 900 ns;
		nmi <= '0';
		
		wait until halt = '1';
		wait for 600 ns;
		
		bus_rq <= '1';
		wait on busak;
		
		nmi <= '1';
		
		wait for 200 ns;
		bus_rq <= '0';
		wait on busak;
		
		wait for 200 ns;
		nmi <= '0';
		
		
		assert false report "fim da simulação!" severity warning;
		wait; -- will wait forever
	end process;
end tb_arch;
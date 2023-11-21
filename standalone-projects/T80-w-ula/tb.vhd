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
			
			KEYB_ADDR : out std_logic_vector(7 downto 0);
			KEYB_DATA : in std_logic_vector(4 downto 0);
			
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
	
	signal keyb_addr : std_logic_vector(7 downto 0);
	signal keyb_data : std_logic_vector(4 downto 0) := "11111";
	
	
	signal mreq, iorq : std_logic := '0';
	signal read_en, write_en : std_logic := '0';
	signal address : std_logic_vector(5 downto 0);
	signal data : std_logic_vector(7 downto 0);
	
begin
	clock_50 <= not clock_50 after 10 ns; -- t=10ns => T=20ns => f=1/20ns = 50 MHz
	-- <= not clock_3_5 after 142.8571428 ns; -- t= 143 ns => T=286 => f=1/286ns =  3,49 MHz
	clk_50 <= clock_50;
	clk_3_5 <= clock_3_5;
	
	KEY(0) <= clk_3_5; 	-- the T80's clock
	KEY(1) <= not reset;	-- reset
	SW(17) <= bus_rq;
	SW(16) <= nmi;
	SW(15) <= int;
	SW(14) <= write_en;
	--SW(13) <= mreq;
	
	busak <= LEDR(16);
	halt <= LEDR(17);
	
	SW(7 downto 0) <= data;
	SW(13 downto 8) <= address;
	
	-- Always sending the key F
	keyb_data <= "10111" when keyb_addr(1) = '0' else "11111";
	
	--SW(1 downto 0) <= video_mode;
	--SW(17) <= native_n_ps2;
	
	
	uut : top port map (
		CLOCK_50 => clk_50,
		SW => SW, 
		KEY => KEY, 
		LEDR => LEDR, 
		LEDG => LEDG,
		
		KEYB_ADDR => keyb_addr,
		KEYB_DATA => keyb_data,
		
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
		reset <= '0';
		--reset <= '1' after 0 ns, '0' after 200 ns;
		
		wait until reset = '0' and halt = '1';
		
		wait for 200 us;
		
		bus_rq <= '1';
		
		wait until busak = '1';
		
		wait for 100 ns;
		
		--address <= "111110";
		address <= "000000"; -- "FFC0"
		data <= x"55";
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		mreq <= '0';
		write_en <= '0';
		--address <= "111111";
		--data <= x"AA";
		address <= "000001"; -- "FFC1"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		write_en <= '0';
		mreq <= '0';
		
		address <= "000010"; -- "FFC2"
		wait for 100 ns;-------------------
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		write_en <= '0';
		mreq <= '0';
		
		address <= "000011"; -- "FFC3"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		write_en <= '0';
		mreq <= '0';
		
		address <= "000100"; -- "FFC4"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		write_en <= '0';
		mreq <= '0';
		
		address <= "000101"; -- "FFC5"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		write_en <= '0';
		mreq <= '0';
		
		address <= "111100"; -- "FFFC"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		

		write_en <= '0';
		mreq <= '0';
		
		address <= "111101"; -- "FFFD"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
				
		write_en <= '0';
		mreq <= '0';
		
		address <= "111110"; -- "FFFE"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
				
		write_en <= '0';
		mreq <= '0';
		
		address <= "111111"; -- "FFFF"
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		
		write_en <= '0';
		mreq <= '0';
		
		wait for 100 ns;
		
		nmi <= '1';
		bus_rq <= '0';
		
		wait until busak = '0';
		wait for 600 ns;
		
		nmi <= '0';
		
		
		--wait for 15622114 ns; -- Value obtained through simulation (to trigger DMA and NMI during INT routine), with only two writes
		wait for 15620614 ns; -- Value obtained through calculation, based on the one above, with 8 more writes
		
		
		bus_rq <= '1';
		
		wait until busak = '1';
		
		wait for 100 ns;
		
		address <= "111110";
		data <= x"55";
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		mreq <= '0';
		write_en <= '0';
		address <= "111111";
		data <= x"AA";
		wait for 100 ns;
		
		write_en <= '1';
		mreq <= '1';
		
		wait for 100 ns;
		
		mreq <= '0';
		write_en <= '0';
		
		wait for 100 ns;
		
		nmi <= '1';
		bus_rq <= '0';
		
		wait until busak = '0';
		wait for 600 ns;
		
		nmi <= '0';
		
		
		assert false report "fim da simulação!" severity warning;
		wait; -- will wait forever
	end process;
end tb_arch;
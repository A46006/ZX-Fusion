library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ula_counters_tb is
end ula_counters_tb;

architecture ula_counters_tb_arch of ula_counters_tb is
	component ula_counters is
		port (
			CLK			: in	std_logic; -- 7MHz
			nTCLKA		: in std_logic; -- Upper Counter Stage Test Clock = nIOREQ & nMREQ & nRD & !nWR
			nTCLKB		: in std_logic; -- Flash Counter Test Clock = nIOREQ and nMREQ and !nRD and nWR
			nRESET		: in	std_logic;
			
			MREQ_n		: in std_logic;
			TOP_ADDRESS	: in std_logic_Vector(1 downto 0);
			
			nINT			: out	std_logic; -- Interrupt
			CPU_CLK		: out	std_logic; -- 3.5MHz
			FLASH_CLK	: out std_logic; -- 1.56 Hz
		   C_out : out std_logic_vector(8 downto 0)
		);
	end component;

	-------------
	-- SIGNALS --
	-------------
	-- TB --
	signal clock_50 : std_logic := '0';
	signal clk_50 : std_logic;
	signal reset : std_logic;
	signal nReset : std_logic := '1';
	
	signal nTCLKA : std_logic := '0';
	signal nTCLKB : std_logic := '0';
	
	signal MREQ_n : std_logic := '0';
	signal TOP_ADDRESS : std_logic_Vector(1 downto 0) := "00";
	
	signal nINT, CPU_CLK, FLASH_CLK : std_logic;
	
begin
	clock_50 <= not clock_50 after 10 ns; -- t=10ns => T=20ns => f=1/20ns = 50 MHz
	clk_50 <= clock_50;
	
	nReset <= not reset;
	
	uut : ula_counters port map (
						CLK => clk_50,
						nTCLKA => nTCLKA,
						nTCLKB => nTCLKB,
						nRESET => nReset,
						MREQ_n => MREQ_n,
						TOP_ADDRESS => TOP_ADDRESS,
						nINT => nINT,
						CPU_CLK => CPU_CLK,
						FLASH_CLK => FLASH_CLK
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
	
end ula_counters_tb_arch;
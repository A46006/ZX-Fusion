library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity top is
	port (
		KEY : in std_logic_vector(3 downto 0);
		SW : in std_logic_vector(17 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(7 downto 0)
	);
end top;

architecture Behavior of top is
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
		   C_out : out std_logic_vector(8 downto 0);
			clkhc6_out : out std_logic
		);
	end component;
	
	component FallingEdge_TFF_RCE is
		port(
			clk : in std_logic;
			E : in std_logic;
			R : in std_logic;
			Q : out std_logic;
			nQ : out std_logic;
			C : out std_logic -- carry
		);
	end component;
	
	signal nINT, CPU_CLK, FLASH_CLK : std_logic;
begin
	ula_counter : ula_counters port map (
			CLK => not KEY(0),
			nTCLKA => '0',
			nTCLKB => '0',
			nRESET => SW(0),
			MREQ_n => '1',
			TOP_ADDRESS => "00",
			nINT => nINT,
			CPU_CLK => CPU_CLK,
			FLASH_CLK => FLASH_CLK,
			C_out => LEDR(8 downto 0),
			clkhc6_out => LEDR(17)
	);
	
	TFF : FallingEdge_TFF_RCE port map (
			clk => not KEY(3),
			E => SW(17),
			R => SW(16),
			Q => LEDG(1),
			nQ => LEDG(0),
			C => LEDG(7)
	);
end Behavior;
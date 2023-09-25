library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ula_counters is
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
end ula_counters;

architecture Behavior of ula_counters is

	component FallingEdge_DFF is
	port( 
		clk : in std_logic;
		D : in std_logic;
		Q : out std_logic;
		nQ : out std_logic
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
	
	signal en_trce1 : std_logic := '0';
	signal en_trce2 : std_logic := '0';

	signal c : unsigned(8 downto 0) := (others => '0');
--	signal c : std_logic_vector(8 downto 0) := (others => '0');
	signal nC : unsigned(8 downto 0);
	
	signal v : unsigned(8 downto 0) := (others => '0'); -- master vertical counter (V8 used for flash)
--	signal v : std_logic_vector(8 downto 0) := (others => '0'); -- master vertical counter (V8 used for flash)
	signal flash_ctr : unsigned(4 downto 0);
	signal flash_clock : std_logic := '0';
	
	signal vsync : std_logic;
	
	-- Used for vertical counter
	signal clkhc6 : std_logic;
	
	-- used as enable for vertical counter's first flip-flop, as well as reset for C8-C6
	signal hcrst : std_logic;
	
	-- TODO use for contention cpu clock control
	signal n_clk_wait : std_logic;
	
	signal contention_mem_zone : std_logic;
	
	signal cpu_stop : std_logic := '0';
	
	-- because modelsim HATES "conversion" functions i.e. "not":
	signal fd0_clk : std_logic := '0';
	signal fd1_clk : std_logic := '0';
	signal fd2_clk : std_logic := '0';
	signal fd3_clk : std_logic := '0';
	signal fd4_clk : std_logic := '0';
	signal fd5_clk : std_logic := '0';
	
begin
	-----------------
	fd0_clk <= not CLK;
	fd1_clk <= not (CLK or nC(0));
	fd2_clk <= not (CLK or nC(0) or nC(1));
	fd3_clk <= not (CLK or nC(0) or nC(1) or nC(2));
	fd4_clk <= not nC(3);
	fd5_clk <= not (nC(3) or nC(4));

	-----------------
	clkhc6 <= not (nTCLKA OR nC(5)); -- should this actually be nC6?
	clkhc6_out <= clkhc6;
	
	hcrst <= not (nC(7) or nC(8));
	
	vsync <= '1' when v(7 downto 2) = "111110" else '0';	
	
	nINT <= '0' when vsync = '1' and v(2 downto 0) = "000" and c(8 downto 6) = "000"
				else '1';
				
	-- page 192 of Chris Smith's ULA book
	n_clk_wait <= '0' when c(3 downto 2) = "00" else '1';
	
	contention_mem_zone <= '1' when TOP_ADDRESS(1 downto 0) = "01" else '0';

	-- 1.56 Hz
	FLASH_CLK <= flash_clock;
	C_out <= std_logic_vector(c);
	-- 3.5MHz
	process(CLK)
	begin
		if (CLK = '1') then -- TODO check modelsim TO SEE IF THIS IS WORKING AS EXPECTED (visually all is good)
		--if (rising_edge(CLK)) then
			if (MREQ_N='1' and contention_mem_zone='1' and 
						n_clk_wait='0') then
				cpu_stop <= '1';
			elsif (cpu_stop='1' and n_clk_wait='1') then
				cpu_stop <= '0';
			end if;
		end if;
	end process;
						
	CPU_CLK <= '1' when cpu_stop = '1'
					else c(0);


	FD0 : FallingEdge_DFF port map(
		clk 	=> fd0_clk,
		D 		=> nC(0),
		Q 		=> c(0),
		nQ 	=> nC(0)
	);

	FD1 : FallingEdge_DFF port map(
		clk 	=> fd1_clk,
		D 		=> nC(1),
		Q 		=> c(1),
		nQ 	=> nC(1)
	);
	
	FD2 : FallingEdge_DFF port map(
		clk 	=> fd2_clk,
		D 		=> nC(2),
		Q 		=> c(2),
		nQ 	=> nC(2)
	);
	
	FD3 : FallingEdge_DFF port map(
		clk 	=> fd3_clk,
		D 		=> nC(3),
		Q 		=> c(3),
		nQ 	=> nC(3)
	);

	FD4 : FallingEdge_DFF port map(
		clk 	=> fd4_clk,
		D 		=> nC(4),
		Q 		=> c(4),
		nQ 	=> nC(4)
	);
	
	FD5 : FallingEdge_DFF port map(
		clk 	=> fd5_clk,
		D 		=> nC(5),
		Q 		=> c(5),
		nQ 	=> nC(5)
	);
	
	TCR : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> '1',
		R		=> hcrst,
		Q		=> C(6),
		nQ		=> nC(6),
		C		=> en_trce1
	);
	
	TRCE1 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_trce1,
		R		=> hcrst,
		Q		=> C(7),
		nQ		=> nC(7),
		C		=> en_trce2
	);
	
	TRCE2 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_trce2,
		R		=> hcrst,
		Q		=> C(8),
		nQ		=> nC(8),
		C		=> open
	);
	
end Behavior;
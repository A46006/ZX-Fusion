library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ula_count is
port (
	CLK			: in	std_logic; -- 7MHz
	nTCLKA		: in std_logic; -- Upper Counter Stage Test Clock = nIOREQ & nMREQ & nRD & !nWR
	nTCLKB		: in std_logic; -- Flash Counter Test Clock = nIOREQ and nMREQ and !nRD and nWR
	nRESET		: in	std_logic;
	
	MREQ_n		: in std_logic;
	IOREQ_n		: in std_logic;
	
	TOP_ADDRESS	: in std_logic_Vector(1 downto 0);
	
	nINT			: out	std_logic; -- Interrupt
	CPU_CLK		: out	std_logic; -- 3.5MHz
	FLASH_CLK	: out std_logic -- 1.56 Hz
	--IOREQGTW3_n	: out std_logic
--	C_out : out std_logic_vector(8 downto 0)
	);
end ula_count;

architecture Behavior of ula_count is

--	component ula_h_counter is
--	port(
--		nCLK7 : in std_logic;
--		nTCLKA : in std_logic;
--		
--		C : out std_logic_vector(8 downto 0);
--		CLKHC6 : out std_logic;
--		HCrst : out std_logic
--	);
--	end component;
--	
--	component ula_v_counter is
--	port(
--		HCrst : in std_logic;
--		CLKHC6 : in std_logic;
--		
--		V : out std_logic_vector(8 downto 0)
--	);
--	end component;
--
--	component ula_f_counter is
--	port(
--		nV8 : in std_logic;
--		nTCLKB : in std_logic;
--		
--		FlashClock : out std_logic
--	);
--	end component;
	
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

	-- Horizontal counter --
	signal en_trce1 : std_logic := '0';
	signal en_trce2 : std_logic := '0';
	
	signal c : unsigned(8 downto 0) := (others => '0');
--	signal c : std_logic_vector(8 downto 0) := (others => '0');
	signal nC : unsigned(8 downto 0) := (others => '1');
	
	-- because modelsim HATES "conversion" functions i.e. "not":
	signal fd0_clk : std_logic := '0';
	signal fd1_clk : std_logic := '0';
	signal fd2_clk : std_logic := '0';
	signal fd3_clk : std_logic := '0';
	signal fd4_clk : std_logic := '0';
	signal fd5_clk : std_logic := '0';
	
	
	-- Vertical counter --
	signal en_vtff1 : std_logic := '0';
	signal en_vtff2 : std_logic := '0';
	signal en_vtff3 : std_logic := '0';
	signal en_vtff4 : std_logic := '0';
	signal en_vtff5 : std_logic := '0';
	signal en_vtff6 : std_logic := '0';
	signal en_vtff7 : std_logic := '0';
	signal en_vtff8 : std_logic := '0';
	
	signal v : unsigned(8 downto 0) := (others => '0'); -- master vertical counter (V8 used for flash)
	signal nV : unsigned(8 downto 0) := (others => '1');
--	signal v : std_logic_vector(8 downto 0) := (others => '0'); -- master vertical counter (V8 used for flash)
	
	signal vrst : std_logic := '0';
	
	-- Flash counter --
	signal clk_flashff : std_logic := '0';
	signal flash_ctr : unsigned(4 downto 0) := (others => '0');
	signal n_flash_ctr : unsigned(4 downto 0) := (others => '0');
	signal flash_clock : std_logic := '0';
	
	-- Video timing --
	signal vsync : std_logic;
	signal v_border_lower : std_logic;
	-- VBorderUpper = v(8)
	signal border : std_logic;
	
	
	-- ULA --
	
	-- Used for vertical counter
	signal clkhc6 : std_logic;
	
	-- used as enable for vertical counter's first flip-flop, as well as reset for C8-C6
	signal hcrst : std_logic;
	
	signal m_wait : std_logic := '0';					-- timing for when contention could occur
	signal n_cpu_clk : std_logic := '1';				-- negated cpu clock
	signal mreq_t23 : std_logic := '0';					-- delayed memory request signal
	signal ioreq_gtw3 : std_logic := '0';				-- delayed i/o request signal
	signal contention_time : std_logic := '0';		-- based on border, cpu clock and request signals
--	signal contention_mem_zone : std_logic;			-- based on address being accessed, or even ioreq (issue 3 ULA)
	signal contention_mem_zone_14 : std_logic;
	signal contention_mem_zone_15 : std_logic;
	
	signal memory_contention : std_logic := '0';		-- combined from all memory contention conditions, to decide cpu clock
	signal io_contention : std_logic := '0';
--	signal cpu_stop : std_logic := '0';
	

begin
	------- Video --------
	
	-- PAL vsync calculation (page 102 of Chris Smith's ULA book)
	vsync <= v(7) and v(6) and v(5) and v(4) and v(3) and (not v(2));-- '1' when v(7 downto 2) = "111110" else '0';	
	
	-- page 100 of Chris Smith's ULA book --
	v_border_lower <= v(7) and v(6);
	border <= v_border_lower or v(8) or c(8);
	--------------------------------------
	
	CPU_CLK <= not n_cpu_clk;
	--IOREQGTW3_n <= not ioreq_gtw3;
	
	clkhc6 <= not (nTCLKA OR nC(5)); -- should this actually be nC6?
	
	hcrst <= c(7) AND c(8);
	
	
	nINT <= (not vsync) or v(2) or v(1) or v(0) or c(8) or c(7) or c(6); --'0' when vsync = '1' and v(2 downto 0) = "000" and c(8 downto 6) = "000"
				--else '1';
				
	-- page 192 of Chris Smith's ULA book
	m_wait <= c(3) or c(2);--'0' when c(3 downto 2) = "00" else '1';
	
	-- page 206 of Chris Smith's ULA book
	contention_time <= not (border or ioreq_gtw3 or mreq_t23 or n_cpu_clk);
	
	contention_mem_zone_14 <= TOP_ADDRESS(0) or (not IOREQ_n); --'1' when TOP_ADDRESS(1 downto 0) = "01" and IOREQ_n = '0' else '0';
	contention_mem_zone_15 <= (not TOP_ADDRESS(1)) or (not IOREQ_n);
	
	memory_contention <= contention_mem_zone_14 and contention_mem_zone_15 and contention_time and m_wait;
	
	
	io_contention <= not (not(m_wait) or border or n_cpu_clk or IOREQ_n or ioreq_gtw3);--m_wait and (not border) and (not n_cpu_clk) and (not IOREQ_n) and (not ioreq_gtw3);
	
	n_cpu_clk <= not (c(0) or memory_contention or io_contention);
	
--	C_out <= std_logic_vector(c);
	
	-- 1.56 Hz
	flash_clock <= flash_ctr(4);
	FLASH_CLK <= flash_clock;
	
	-- Gated D latches for delaying memreq and ioreq signals
	process(nRESET, n_cpu_clk)
	begin
		if (nRESET = '0') then
			mreq_t23 <= '0';
			ioreq_gtw3 <= '0';
		else
			if (n_cpu_clk = '1') then -- active low enable
				mreq_t23 <= not MREQ_n;
				ioreq_gtw3 <= not IOREQ_n;
			end if;
		end if;
	end process;
	
--	-- 3.5MHz
--	process(CLK)
--	begin
--		if (CLK = '1') then -- TODO check modelsim TO SEE IF THIS IS WORKING AS EXPECTED (visually all is good)
--		--if (rising_edge(CLK)) then
--			if (MREQ_N='1' and contention_mem_zone='1' and 
--						m_wait='0') then
--				cpu_stop <= '1';
--			elsif (cpu_stop='1' and m_wait='1') then
--				cpu_stop <= '0';
--			end if;
--		end if;
--	end process;
--						
--	CPU_CLK <= '1' when cpu_stop = '1'
--					else c(0);



--	h_counter : ula_h_counter port map(
--		nCLK7		=> not CLK,
--		nTCLKA	=> nTCLKA,
--		
--		C			=> c,
--		CLKHC6	=> clkhc6,
--		HCrst		=> hcrst
--	);
--	
--	v_counter : ula_v_counter port map(
--		HCrst		=> hcrst,
--		CLKHC6	=> clkhc6,
--		
--		V			=> v
--	);
--	
--	f_counter : ula_f_counter port map(
--		nV8		=> not v(8),
--		nTCLKB	=> nTCLKB,
--		
--		FlashClock	=> flash_clock
--	);

--	FD0 : FallingEdge_DFF port map(
--		clk 	=> CLK,
--		D 		=> nC(0),
--		Q 		=> c(0),
--		nQ 	=> nC(0)
--	);


--	-- Horizontal Counter
--	process(CLK)
--	begin
--		
--		if (rising_edge(CLK)) then
--			if (nRESET = '0') then
--				c <= (others => '0');
--				v <= (others => '0');
--				flash_ctr <= (others => '0');
--			else
--				if (c < "110111111") then
--					c <= c + 1;
--				else
--					c <= (others => '0');
--					-- add clkhc6 check for vertical counter?
--					if (nTCLKA = '1') then
--						if (v < "100110111") then -- V before reaching 312
--							v <= v + 1;
--						else
--							v <= (others => '0');
--							if (nTCLKB = '1') then
--								if (flash_ctr < "11111") then
--									flash_ctr <= flash_ctr + 1;
--								else
--									flash_ctr <= (others => '0');
--									flash_clock <= not flash_clock;
--								end if;
--							end if;
--						end if;
--					end if;
--				end if;
--			end if;
--		end if;
--	end process;

	-- HORIZONTAL COUNTER --

	
	fd0_clk <= not CLK;
	fd1_clk <= not (CLK or nC(0));
	fd2_clk <= not (CLK or nC(0) or nC(1));
	fd3_clk <= not (CLK or nC(0) or nC(1) or nC(2));
	fd4_clk <= not nC(3);
	fd5_clk <= not (nC(3) or nC(4));
	
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
	
	-- VERTICAL COUNTER --
	
	VTFF0 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> hcrst,
		R		=> '0',
		Q		=> v(0),
		nQ		=> nV(0),
		C		=> en_vtff1
	);
	
	VTFF1 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff1,
		R		=> '0',
		Q		=> v(1),
		nQ		=> nV(1),
		C		=> en_vtff2
	);
		
	VTFF2 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff2,
		R		=> '0',
		Q		=> v(2),
		nQ		=> nV(2),
		C		=> en_vtff3
	);
	
	vrst <= not ((not en_vtff3) or nV(5) or nV(4) or nV(8));
	
	VTFF3 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff3,
		R		=> vrst,
		Q		=> v(3),
		nQ		=> nV(3),
		C		=> en_vtff4
	);
	
	VTFF4 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff4,
		R		=> vrst,
		Q		=> v(4),
		nQ		=> nV(4),
		C		=> en_vtff5
	);
		
	VTFF5 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff5,
		R		=> vrst,
		Q		=> v(5),
		nQ		=> nV(5),
		C		=> en_vtff6
	);
	
	VTFF6 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff6,
		R		=> vrst,
		Q		=> v(6),
		nQ		=> nV(6),
		C		=> en_vtff7
	);
	
	VTFF7 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff7,
		R		=> vrst,
		Q		=> v(7),
		nQ		=> nV(7),
		C		=> en_vtff8
	);
		
	VTFF8 : FallingEdge_TFF_RCE port map(
		clk	=> clkhc6,
		E		=> en_vtff8,
		R		=> vrst,
		Q		=> v(8),
		nQ		=> nV(8),
		C		=> open
	);
	
	-- FLASH COUNTER --
	clk_flashff <= not (nV(8) or nTCLKB);
	
	FlashFD0 : FallingEdge_DFF port map(
		clk 	=> clk_flashff,
		D 		=> n_flash_ctr(0),
		Q 		=> flash_ctr(0),
		nQ 	=> n_flash_ctr(0)
	);
	
	FlashFD1 : FallingEdge_DFF port map(
		clk 	=> flash_ctr(0),
		D 		=> n_flash_ctr(1),
		Q 		=> flash_ctr(1),
		nQ 	=> n_flash_ctr(1)
	);
	
	FlashFD2 : FallingEdge_DFF port map(
		clk 	=> flash_ctr(1),
		D 		=> n_flash_ctr(2),
		Q 		=> flash_ctr(2),
		nQ 	=> n_flash_ctr(2)
	);
	
	FlashFD3 : FallingEdge_DFF port map(
		clk 	=> flash_ctr(2),
		D 		=> n_flash_ctr(3),
		Q 		=> flash_ctr(3),
		nQ 	=> n_flash_ctr(3)
	);
	
	FlashFD4 : FallingEdge_DFF port map(
		clk 	=> flash_ctr(3),
		D 		=> n_flash_ctr(4),
		Q 		=> flash_ctr(4),
		nQ 	=> n_flash_ctr(4)
	);
	
end Behavior;
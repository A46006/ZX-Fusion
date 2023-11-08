library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
	port (
		CLOCK_50 : IN std_logic;
		SW : in std_logic_vector(17 downto 0);
		KEY : in std_logic_vector(3 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		LEDG : out std_logic_vector(7 downto 0);
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6));
end top;

architecture Behavior of top is
	COMPONENT conv_7seg IS
		PORT ( number : IN STD_LOGIC_VECTOR(7 downto 0);
			 num1, num0 : OUT STD_LOGIC_VECTOR(0 TO 6));
	END COMPONENT;

	component T80a is
		port(
			RESET_n         : in std_logic;
			CLK_n           : in std_logic;
			WAIT_n          : in std_logic;
			INT_n           : in std_logic;
			NMI_n           : in std_logic;
			BUSRQ_n         : in std_logic;
			M1_n            : out std_logic;
			MREQ_n          : out std_logic;
			IORQ_n          : out std_logic;
			RD_n            : out std_logic;
			WR_n            : out std_logic;
			RFSH_n          : out std_logic;
			HALT_n          : out std_logic;
			BUSAK_n         : out std_logic;
			A                       : out std_logic_vector(15 downto 0);
			D                       : inout std_logic_vector(7 downto 0));
	end component;
	
	component ram IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			clken		: IN STD_LOGIC  := '1';
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rden		: IN STD_LOGIC  := '1';
			wren		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;
	
	-- COUNTER RELATED
	signal count : std_logic_vector(2 downto 0); -- minimum of 3 clocks for reset
	signal reset_ctr_start : std_logic := '1';
	signal reset_ctr_manual : std_logic;
	
	-- DIRECTLY CPU RELATED
	signal reset_n, clock_n, bus_rq_n : std_logic := '1';
	signal m1_n, mem_req_n, read_n, write_n, mem_refresh_n, halt_n, busak_n: std_logic;
	signal cpu_address, address, in_address : std_logic_vector(15 downto 0);
	signal cpu_data, cpu_data_i, cpu_data_o : std_logic_vector(7 downto 0);
	
	signal io_req_n : std_logic; -- unnecessary for now but here anyway
	
	signal data_view : std_logic_vector(7 downto 0);
	
begin
	address_low : conv_7seg port map (address(7 downto 0), HEX1, HEX0);
	address_high : conv_7seg port map (address(15 downto 8), HEX3, HEX2);
	data_7seg : conv_7seg port map(data_view, HEX7, HEX6);
	HEX5 <= "0001000";
	HEX4 <= "1111110";

	z80 : T80a port map (
			RESET_n => reset_n, CLK_n => clock_n, WAIT_n => '1', INT_n => '1', NMI_n => '1', BUSRQ_n => bus_rq_n,
			M1_n => m1_n, MREQ_n => mem_req_n, IORQ_n => io_req_n, RD_n => read_n, WR_n => write_n, RFSH_n => mem_refresh_n,
			HALT_n => halt_n, BUSAK_n => busak_n,
			A => cpu_address, D => cpu_data);

	cpu_data <= "ZZZZZZZZ" when read_n = '1' and write_n = '0' else cpu_data_i; -- READ
	cpu_data_o <= "ZZZZZZZZ" when read_n = '0' and write_n = '1' else cpu_data; -- WRITE

			
	clock_n <= KEY(0);
	reset_ctr_manual <= not KEY(1);
	
	data_view <= cpu_data when read_n = '0' and write_n = '1' else cpu_data_o;
	LEDG <= data_view;
	
	mem: ram port map (
			address	=> address,
			clken		=> not mem_req_n,
			clock		=> CLOCK_50,
			data		=> cpu_data_o,
			rden		=> not read_n,
			wren		=> not write_n,
			q			=> cpu_data_i
		);
	
	bus_rq_n <= not SW(17);
	in_address(7 downto 0) <= SW(7 downto 0);
	address <= in_address when busak_n = '0' else cpu_address;
	LEDR(15 downto 0) <= address;
	
	LEDG(0) <= not busak_n;
	LEDR(17) <= not read_n;
	LEDR(16) <= not write_n;

	--cpu_data_i <= SW(7 downto 0);
	
	-- COUNTER --
	process(clock_n, reset_ctr_manual)
	begin
		if (falling_edge(clock_n)) then
			if ((reset_ctr_start = '1' or reset_ctr_manual = '1') and reset_n = '1') then -- beginning, turn on reset
				reset_n <= '0';
				
			elsif (count(2) = '0') then
				count <= unsigned(count) + '1'; 
			elsif (count(2) = '1' and reset_n <= '0') then
				reset_n <= '1';
				reset_ctr_start <= '0';
				-- should I set reset_ctr_manual to low here?
			end if;
		end if;
	end procesS;
	
end Behavior;

-- TEST CODE
--#define     progStart   $0000
--.org        progStart
--		ld	hl, 4000h	-- ?
--   	ld	A, (hl)	--3 CLOCKS
--  	add A, 1	-- ?
--		ld	(hl), A	--3 clocks
--
-- HEX:
--	21		0x0000
-- 00		0x0001
-- 40		0x0002
-- 7E		0x0003
-- C6		0x0004
-- 01		0x0005
-- 77		0x0006
--
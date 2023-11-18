library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FallingEdge_DFF is
	port(
		clk : in std_logic;
		nRESET : in std_logic;
		SET : in std_logic;
		D : in std_logic;
		EN : in std_logic;
		Q : out std_logic;
		nQ : out std_logic
	);
end FallingEdge_DFF;

architecture Behavior of FallingEdge_DFF is
	signal internal_q : std_logic;
begin
	
	Q <= internal_q;
	nQ <= not internal_q;

	internal_q <= '0' when nRESET = '0' else '1' when SET = '1' else D WHEN falling_edge(clk) and EN = '1';
	
--	process(clk)
--	begin
--		if (falling_edge(clk)) then
--			internal_q <= D;
--		end if;
--	end process;
end Behavior;
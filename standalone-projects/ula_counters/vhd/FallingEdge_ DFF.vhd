library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FallingEdge_DFF is
	port(
		clk : in std_logic;
		D : in std_logic;
		Q : out std_logic;
		nQ : out std_logic
	);
end FallingEdge_DFF;

architecture Behavior of FallingEdge_DFF is
	signal internal_q : std_logic;
begin
	
	Q <= internal_q;
	nQ <= not internal_q;

	process(clk)
	begin
		if (falling_edge(clk)) then
			internal_q <= D;
		end if;
	end process;
end Behavior;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FallingEdge_TFF_RCE is
	port(
		clk : in std_logic;
		E : in std_logic;
		R : in std_logic;
		Q : out std_logic;
		nQ : out std_logic;
		C : out std_logic -- carry
	);
end FallingEdge_TFF_RCE;

architecture Behavior of FallingEdge_TFF_RCE is
	signal internal_Q : std_logic := '0';
	signal d : std_logic := '1';
begin
	Q <= internal_Q;
	nQ <= not internal_Q;
	d <= not internal_Q;
	C <= internal_Q and E;

	process(clk)
	begin
		if (falling_edge(clk)) then
			if (R = '1') then
				internal_Q <= '0';
			else
				if (E = '1') then
					internal_Q <= d;
				end if;
			end if;
		end if;
	end process;
end Behavior;

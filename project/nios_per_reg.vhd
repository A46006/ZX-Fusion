library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nios_per_reg is
	port (
		clk						: in std_logic;
	
		address_in				: in std_logic_vector(15 downto 0);
		data_in					: in std_logic_vector(7 downto 0);
		rd_n_in, wr_n_in		: in std_logic;
		
		address_out				: out std_logic_vector(15 downto 0) := (others => '0');
		data_out					: out std_logic_vector(7 downto 0) := (others => '0');
		rd_n_out, wr_n_out	: out std_logic := '1';
		en_out					: out std_logic := '0';
		
		reset, oe				: in std_logic
	);
end nios_per_reg;

architecture Behavior of nios_per_reg is
begin

	process(clk, reset)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				address_out <= (others => '0');
				data_out <= (others => '0');
				rd_n_out <= '1';
				wr_n_out <= '1';
				en_out <= '0';
			else
				if (oe = '1') then
					address_out <= address_in;
					data_out <= data_in;
					rd_n_out <= rd_n_in;
					wr_n_out <= wr_n_in;
					en_out <= '1';
				end if;
			end if;
		end if;
	end process;
end Behavior;
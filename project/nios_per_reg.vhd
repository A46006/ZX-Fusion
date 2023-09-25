library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity nios_per_reg is
	port (
		address_in				: in std_logic_vector(15 downto 0);
		data_in					: in std_logic_vector(7 downto 0);
		rd_n_in, wr_n_in		: in std_logic;
		
		address_out				: out std_logic_vector(15 downto 0) := (others => '0');
		data_out					: out std_logic_vector(7 downto 0) := (others => '0');
		rd_n_out, wr_n_out	: out std_logic := '1';
		en_out					: out std_logic := '0';
		
		reset, oe					: in std_logic
	);
end nios_per_reg;

architecture Behavior of nios_per_reg is
	signal state : std_logic := '0';
begin



--	address_out <= (others => '0') when reset = '1' else address_in when oe = '1';
--	data_out <= (others => '0') when reset = '1' else data_in when oe = '1';
--	rd_n_out <= '0' when reset = '1' else rd_n_in when oe = '1';
--	wr_n_out <= '0' when reset = '1' else wr_n_in when oe = '1';
--	en_out <= '0' when  reset = '1' else '1' when oe = '1';
	
	process(reset, oe, rd_n_in, wr_n_in)
	begin
		if (reset = '1') then
			address_out <= (others => '0');
			data_out <= (others => '0');
			rd_n_out <= '1';
			wr_n_out <= '1';
			en_out <= '0';
		else
--			if (wr_n_in = '0') then
--				if (oe = '1') then
--					wr_n_out <= wr_n_in;
--				end if;
--			end if;
			if (oe = '1') then
				address_out <= address_in;
				data_out <= data_in;
				en_out <= '1';
				if (wr_n_in = '0') then
					wr_n_out <= '0';
				elsif (rd_n_in = '0') then
					rd_n_out <= '0';				
				end if;
			end if;
		end if;
	end process;
end Behavior;
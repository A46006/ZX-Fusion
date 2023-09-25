library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2_controller_test_tb is
end PS2_controller_test_tb;

architecture Behavior of PS2_controller_test_tb is

	procedure send_through_PS2(
		signal data : in std_logic_vector(7 downto 0);
		signal PS2_DATA : out std_logic;
		signal PS2_CLK : out std_logic
	) is
		variable odd_parity : std_logic := '1';
	begin
		-- Start
		PS2_DATA <= '0';
		PS2_CLK <= '0';
		wait for 200 ns;
		PS2_CLK <= '1';
		wait for 200 ns;
	
		for i in 0 to 7 loop
			PS2_DATA <= data(i);
			PS2_CLK <= '0';
			wait for 200 ns;
			PS2_CLK <= '1';
			odd_parity := odd_parity xor data(i);
			wait for 200 ns;
		end loop;
		
		-- Parity
		PS2_DATA <= odd_parity;
		PS2_CLK <= '0';
		wait for 200 ns;
		PS2_CLK <= '1';
		wait for 200 ns;
		
		-- End
		PS2_DATA <= '1';
		PS2_CLK <= '0';
		wait for 200 ns;
		PS2_CLK <= '1';
		wait for 200 ns;
	end procedure;
	
	component PS2_controller_test
		port (
			CLOCK_50 : IN std_logic;
			SW : in std_logic_vector(17 downto 0);
			LEDR : out std_logic_vector(17 downto 0);
			PS2_CLK, PS2_DAT : inout std_logic;
			HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6));
	end component;
	
	signal clock : std_logic := '0';
	signal reset : std_logic := '1';
	
	signal LEDR : std_logic_vector(17 downto 0);
	signal SW : std_logic_vector(17 downto 0);
	signal rdaddress : std_logic_vector(7 downto 0) := X"00";
	signal HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : STD_LOGIC_VECTOR(0 to 6);
	signal PS2_CLK, PS2_DAT : std_logic := '1';
	signal test_data : std_logic_vector(7 downto 0);
	
begin

	uut : PS2_controller_test port map (clock, SW, LEDR, PS2_CLK, PS2_DAT, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7);

	clock <= not clock after 10 ns; -- t=10ns / T=20ns / f = 1/20ns = 50=MHz
			
	sW(17) <= reset;
			
	HEX7 <=  (others => '1');
	HEX6 <=  (others => '1');
	HEX5 <=  (others => '1');
	HEX4 <=  (others => '1');
	HEX3 <=  (others => '1');
	HEX2 <=  (others => '1');
	
	PS2_controller_test_tb : process
	begin
		wait for 100 ns;
		reset <= '0';
		
		wait for 200 us;
		PS2_CLK <= '0';
		wait for 200 ns;
		PS2_CLK <= '1';
		wait for 200 ns;
		
		PS2_CLK <= '0';
		wait for 200 ns;
		PS2_CLK <= '1';
		wait for 200 ns;
		
		PS2_CLK <= '0';
		wait for 200 ns;
		PS2_CLK <= '1';
		wait for 200 ns;
		
		-- Q Press
		test_data <= X"15";
		send_through_PS2(test_data, PS2_DAT, PS2_CLK);
		wait for 50 ns;
		
		-- Q Release
		test_data <= X"F0";
		send_through_PS2(test_data, PS2_DAT, PS2_CLK);
		test_data <= X"15";
		send_through_PS2(test_data, PS2_DAT, PS2_CLK);
		
		wait for 50 ns;
		
		assert false report "fim da simulação!" severity warning;
		wait; -- will wait forever
	end process;

end Behavior;

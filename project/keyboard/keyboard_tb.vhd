library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity keyboard_tb is

end keyboard_tb;

architecture tb of keyboard_tb is
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

	component keyboard_top is
		port(
			CLOCK, PS2_CLOCK, PS2_DATA, RESET : in std_logic;
			NATIVE_DATA : in std_logic_vector(4 downto 0);
			PS2nNat : in std_logic;
			ADDRESS : in std_logic_vector(7 downto 0);
			KEY_DATA : out std_logic_vector(4 downto 0)
		);
	end component;
	
	signal CLK : std_logic := '0';
	signal RESET : std_logic := '1';
	signal PS2_CLK : std_logic := '1';
	signal PS2_DATA : std_logic := '1';
--	signal DATA  : std_logic_vector(7 downto 0);
	
	signal PS2_nNative : std_logic;
	signal native_data, key_data : std_logic_vector(4 downto 0);
	signal address : std_logic_vector(7 downto 0) := x"FD";
	
	signal test_data : std_logic_vector(7 downto 0);
begin
  uut : keyboard_top port map(
    CLK, PS2_CLK, PS2_DATA, RESET, native_data, PS2_nNative, address, key_data
	);
  
  CLK <= not CLK after 10 ns; -- t=10ns / T=20ns / f = 1/20ns = 50=MHz
    

	keyboard_tb : process
	begin
		wait for 100 ns;
		RESET <= '0';
		PS2_nNative <= '1';

		-- Q Press
		test_data <= X"15";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		address <= x"FB";
		wait for 50 ns;
		
		-- Q Release
		test_data <= X"F0";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		test_data <= X"15";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		address <= x"EF";
		
		-- SHIFT hold
		test_data <= X"59";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		-- 0 Press and release
		test_data <= X"45";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		test_data <= X"F0";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		test_data <= X"45";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		-- SHIFT release
		test_data <= X"F0";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		test_data <= X"59";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		
		
	
		-- SHIFT hold
		test_data <= X"59";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		-- 0 Press
		test_data <= X"45";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		-- SHIFT Release
		test_data <= X"F0";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		test_data <= X"59";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		-- 0 release
		test_data <= X"F0";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		test_data <= X"45";
		send_through_PS2(test_data, PS2_DATA, PS2_CLK);
		
		wait for 50 ns;
		
		assert false report "fim da simulação!" severity warning;
		wait; -- will wait forever
	end process;

end tb;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use ieee.numeric_std.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PS2_controller_test is
	port (
		CLOCK_50 : IN std_logic;
		SW : in std_logic_vector(17 downto 0);
		LEDR : out std_logic_vector(17 downto 0);
		PS2_CLK, PS2_DAT : inout std_logic;
		HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7 : out STD_LOGIC_VECTOR(0 to 6));
end PS2_controller_test;

architecture Behavior of PS2_controller_test is
--	component ps2_intf
--		port(
--		CLK			:	in	std_logic;
--		nRESET		:	in	std_logic;
--		
--		-- PS/2 interface (could be bi-dir)
--		PS2_CLK		:	inout	std_logic;
--		PS2_DATA	:	inout	std_logic;
--		
--		-- Byte-wide data interface - only valid for one clock
--		-- so must be latched externally if required
--		DATA		:	out	std_logic_vector(7 downto 0);
--		VALID		:	out	std_logic;
--		ERROR		:	out	std_logic
--		);
--	end component;
	
	component PS2_Controller
		PORT(
			CLOCK_50, RESET : in std_logic;
			THE_COMMAND : in std_logic_vector(7 downto 0);
			SEND_COMMAND : in std_logic;
			
			PS2_CLK : inout std_logic;
			PS2_DAT : inout std_logic;

			RECEIVED_DATA : out std_logic_vector(7 downto 0);
			RECEIVED_DATA_EN : out std_logic;
			COMMAND_WAS_SENT : out std_logic;
			ERROR_COMMUNICATION_TIMED_OUT : out std_logic
		);
	end component;
	
	component key_mem
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component;
	
	component conv_7seg
		PORT ( number : IN STD_LOGIC_VECTOR(7 downto 0);
			 num1, num0 : OUT STD_LOGIC_VECTOR(0 TO 6));
	end component;
	
	signal reset : std_logic := '0';
	signal prefix, scan_code, prefix_s, scan_code_s : std_logic_vector(7 downto 0);
	signal error, valid, been_read: std_logic;
	signal wraddress, rdaddress : std_logic_vector(7 downto 0);
	
	signal ps2_command : std_logic_vector(7 downto 0);
	signal scan_code_en, ps2_send : std_logic;
	
	signal numlock : std_logic := '1';
	signal capslock : std_logic := '0';
	signal numlock_led, capslock_led : std_logic := '0';
	signal release : std_logic := '0';
	signal led_set_state : std_logic_vector(1 downto 0) := "00";
	
	-- Build an enumerated type for the state machine
	type LED_state_type is (s0, s1, s2);--, s3, s4, s5);

	-- Register to hold the current state
	signal LED_state   : LED_state_type;
begin
--	ps2_interface : ps2_intf port map (CLOCK_50, not reset, PS2_CLK, PS2_DAT, scan_code, valid, error);
	key_memory : key_mem port map (CLOCK_50, scan_code, rdaddress, wraddress, scan_code_en, scan_code_s);
	--conv_7seg_1 : conv_7seg port map (prefix_s, HEX3, HEX2);
	conv_7seg_0 : conv_7seg port map (scan_code_s, HEX1, HEX0);
	PS2 : PS2_Controller port map (CLOCK_50, reset, ps2_command, ps2_send, PS2_CLK, PS2_DAT,
											scan_code, scan_code_en, valid, error);
	
	process (reset, CLOCK_50) is
	begin
		if (reset = '1') then
			wraddress <= (others => '0');
		elsif (rising_edge(CLOCK_50)) then
			if (scan_code_en = '1') then
				wraddress <= wraddress + '1';--std_logic_vector(to_unsigned(wraddress) +1);
			end if;
		end if;
	end process;
	
	
	process (CLOCK_50, reset) is
	begin
		if (rising_edge(CLOCK_50)) then
			if (reset = '1') then
				release <= '0';
				numlock <= '1';
				capslock <= '0';
			else
				if (scan_code_en = '1') then
					if (scan_code = X"F0") then
						release <= '1';
					else
						if (release = '0') then
							case scan_code is
								when x"77" => numlock <= not numlock;
								when x"58" => capslock <= not capslock;
								when others => null;
							end case;
						end if;
						release <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	
	process (numlock, capslock, CLOCK_50, reset) is
	begin
		if (numlock_led /= numlock or capslock_led /= capslock) then
			if (falling_edge(CLOCK_50)) then
				if (reset = '1') then
					LED_state <= s0;
					ps2_command <= X"00";
					ps2_send <= '0';
				else
					case(LED_state) is
						when s0 =>
							ps2_command <= X"ED";
							ps2_send <= '1';
							LED_state <= s1;
						when s1 =>
							ps2_send <= '0';
							if (valid = '1') then
								ps2_command <= "00000" & capslock & numlock & "0";
								ps2_send <= '1';
								LED_state <= s2;
							end if;
						when s2 =>
							ps2_send <= '0';
							if (valid = '1') then
								numlock_led <= numlock;
								capslock_led <= capslock;
								LED_state <= s0;
							end if;
					end case;
--					if (led_set_state = "00") then
--						ps2_command <= X"ED";
--						ps2_send <= '1';
--						led_set_state <= "01";
--					elsif (led_set_state = "01") then
--						ps2_send <= '0';
--						if (valid = '1') then
--							ps2_command <= "00000" & capslock & numlock & "0";
--							ps2_send <= '1';
--							led_set_state <= "10";
--						end if;
--					elsif (led_set_state = "10") then
--						ps2_send <= '0';
--						if (valid = '1') then
--							numlock_led <= numlock;
--							capslock_led <= capslock;
--							led_set_state <= "00";
--						end if;
--					end if;
				end if;
			end if;
		end if;
	end process;

-- LED State machine advance logic --
--	process (numlock, capslock, CLOCK_50, reset)
--	begin
--		if (falling_edge(CLOCK_50)) then
--			if (reset = '1') then
--				LED_state <= s0;
--			else
--				case LED_state is
--					when s0=> -- Idle
--						if (numlock_led /= numlock or capslock_led /= capslock) then
--							LED_state <= s1;
--						else
--							LED_state <= s0;
--						end if;
--					when s1=> -- Send command
--						if (ps2_send = '1') then
--							LED_state <= s2;
--						else
--							LED_state <= s1;
--						end if;
--					when s2=> -- Await ACK
--						if (valid = '1' or scan_code = X"FA") then
--							LED_state <= s3;
--						elsif (error = '1') then
--							LED_state <= s0;
--						else
--							LED_state <= s2;
--						end if;
--					when s3 => -- Send LED data
--						if (ps2_send = '1') then
--							LED_state <= s4;
--						else
--							LED_state <= s3;
--						end if;
--					when s4 => -- Await ACK
--						if (valid = '1' or scan_code = X"FA") then
--							LED_state <= s5;
--						elsif (error = '1') then
--							LED_state <= s0;
--						else
--							LED_state <= s4;
--						end if;
--					when s5 => -- Update LED regs
--						if (numlock_led = numlock and capslock_led = capslock) then
--							LED_state <= s0;
--						else
--							LED_state <= s5;
--						end if;
--				end case;
--			end if;
--		end if;
--	end process;
--	
--	LEDR(4 downto 2) <= "000" when LED_state = s0 else
--								"001" when LED_state = s1 else
--								"010" when LED_state = s2 else
--								"011" when LED_state = s3 else
--								"100" when LED_state = s4 else
--								"101" when LED_state = s5;
--	
--	-- LED state machine outputs --
--	process (LED_state)
--	begin
--		case LED_state is
--			when s0 => -- Idle
--				--LEDR(4 downto 2) <= "000";
----				null;
--			when s1 => -- Send command
--				ps2_command <= X"ED"; -- LED change command
--				ps2_send <= '1';
----				LEDR(4 downto 2) <= "001";
--			when s2 => -- Await ACK
--				ps2_send <= '0';
--			when s3 => -- Send LED data
--				ps2_command <= "00000" & capslock & numlock & "0";
--				ps2_send <= '1';
----				LEDR(4 downto 2) <= "011";
--			when s4 => -- Await ACK
--				ps2_send <= '0';
--			when s5 => -- Update LED regs
--				numlock_led <= numlock;
--				capslock_led <= capslock;
--		end case;
--	end process;
	
	LEDR(17) <= valid;
	LEDR(0) <= error;
	
	LEDR(8) <= capslock;
	LEDR(3 downto 2) <= led_set_state;
	
	reset <= SW(17);
	rdaddress <= SW(7 downto 0);
	
	HEX7 <=  (others => '1');
	HEX6 <=  (others => '1');
	HEX5 <=  (others => '1');
	HEX4 <=  (others => '1');
	HEX3 <=  (others => '1');
	HEX2 <=  (others => '1');

end Behavior;

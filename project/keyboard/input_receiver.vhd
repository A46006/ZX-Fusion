library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.constants.ALL;

entity input_receiver is
	port(
		CLOCK, RESET, VALID : in std_logic;
		ADDRESS, PS2_SCAN_CODE : in std_logic_vector(7 downto 0); -- A15 to A8
		NATIVE_DATA : in std_logic_vector(4 downto 0);
		NATnPS2 : in std_logic;
		KEY_DATA : out std_logic_vector(4 downto 0); -- ZX Spectrum formatted keyboard data
			
		JOY1_STATE : in std_logic_vector(7 downto 0); 
		JOY2_STATE : in std_logic_vector(7 downto 0); 
			
		PS2_COMMAND : out std_logic_vector(7 downto 0);
		PS2_COMMAND_EN : out std_logic;
		PS2_COMMAND_ACK, PS2_COMMAND_ERR : in std_logic
	);
end input_receiver;

architecture Behavior of input_receiver is
	procedure clear_halfrows(
							signal half_row_0 : out std_logic_vector(4 downto 0);
							signal half_row_1 : out std_logic_vector(4 downto 0);
							signal half_row_2 : out std_logic_vector(4 downto 0);
							signal half_row_3 : out std_logic_vector(4 downto 0);
							signal half_row_4 : out std_logic_vector(4 downto 0);
							signal half_row_5 : out std_logic_vector(4 downto 0);
							signal half_row_6 : out std_logic_vector(4 downto 0);
							signal half_row_7 : out std_logic_vector(4 downto 0)
							) is
	begin
		half_row_0 <= (others => '1');
		half_row_1 <= (others => '1');
		half_row_2 <= (others => '1');
		half_row_3 <= (others => '1');
		half_row_4 <= (others => '1');
		half_row_5 <= (others => '1');
		half_row_6 <= (others => '1');
		half_row_7 <= (others => '1');
	end procedure clear_halfrows;

	-- ps2 keyboard half row values depending on address value, and final combined value
	signal PS2_converted_data, 
		half_row_0_o, half_row_1_o, half_row_2_o, half_row_3_o, 
		half_row_4_o, half_row_5_o, half_row_6_o, half_row_7_o : std_logic_vector(4 downto 0);
		
	-- sinclair joystick half row values depending on address value, and final combined value
	signal sinclair_converted_data,
		joy2_row_2_o, joy2_row_3_o, joy1_row_4_o, joy1_row_5_o : std_logic_vector(4 downto 0);
	
	signal half_row_0, half_row_1, half_row_2, half_row_3, 
		half_row_4, half_row_5, half_row_6, half_row_7 : std_logic_vector(4 downto 0) := (others => '1');
		
	-- Main (standard) keys --
	signal joy1_row_4, joy2_row_3 : std_logic_vector(4 downto 0) := (others => '1');
	
	-- Extra keys --
	signal joy1_row_5, joy2_row_2 : std_logic_vector(4 downto 0) := (others => '1');
				
	-- Modifiers and key information --
	signal release, extended, shift, alt : std_logic := '0';
	signal numlock : std_logic := '1';
	signal capslock : std_logic := '0';
	signal numlock_led, capslock_led : std_logic := '0'; -- LED state
	
	-- Build an enumerated type for the state machine
	type LED_state_type is (s0, s1, s2);--, s3, s4, s5);

	-- Register to hold the current state
	signal LED_state   : LED_state_type;
begin
	KEY_DATA <= (NATIVE_DATA AND sinclair_converted_data) when NATnPS2 = '1' else (PS2_converted_data and sinclair_converted_data);
	
	
	PS2_converted_data <= half_row_0_o AND half_row_1_o AND half_row_2_o AND half_row_3_o AND 
		half_row_4_o AND half_row_5_o AND half_row_6_o AND half_row_7_o;
	
	-- Each half-row processed seperately to support multiple half-rows being checked simultaneously
	half_row_0_o <= "11111" when ADDRESS(0) = '1' else half_row_0; -- A8
	half_row_1_o <= "11111" when ADDRESS(1) = '1' else half_row_1; -- A9
	half_row_2_o <= "11111" when ADDRESS(2) = '1' else half_row_2; -- A10
	half_row_3_o <= "11111" when ADDRESS(3) = '1' else half_row_3; -- A11
	half_row_4_o <= "11111" when ADDRESS(4) = '1' else half_row_4; -- A12
	half_row_5_o <= "11111" when ADDRESS(5) = '1' else half_row_5; -- A13
	half_row_6_o <= "11111" when ADDRESS(6) = '1' else half_row_6; -- A14
	half_row_7_o <= "11111" when ADDRESS(7) = '1' else half_row_7; -- A15
	
	
	-- PS2 and sinclair joystick processed seperately to allow controller to work even during native keyboard use
	sinclair_converted_data <= joy2_row_2_o AND joy2_row_3_o AND joy1_row_4_o AND joy1_row_5_o;
	
	joy2_row_2_o <= "11111" when ADDRESS(2) = '1' else joy2_row_2; -- A10
	joy2_row_3_o <= "11111" when ADDRESS(3) = '1' else joy2_row_3; -- A11
	joy1_row_4_o <= "11111" when ADDRESS(4) = '1' else joy1_row_4; -- A12
	joy1_row_5_o <= "11111" when ADDRESS(5) = '1' else joy1_row_5; -- A13
	
	-- LED state machine --
	process (numlock, capslock, CLOCK, reset) is
	begin
		if (numlock_led /= numlock or capslock_led /= capslock) then
			if (falling_edge(CLOCK)) then
				if (reset = '1') then
					LED_state <= s0;
					PS2_COMMAND <= X"00";
					PS2_COMMAND_EN <= '0';
				else
					case(LED_state) is
						when s0 =>
							PS2_COMMAND <= X"ED";
							PS2_COMMAND_EN <= '1';
							LED_state <= s1;
						when s1 =>
							PS2_COMMAND_EN <= '0';
							if (PS2_COMMAND_ACK = '1') then
								PS2_COMMAND <= "00000" & capslock & numlock & "0";
								PS2_COMMAND_EN <= '1';
								LED_state <= s2;
							end if;
						when s2 =>
							PS2_COMMAND_EN <= '0';
							if (PS2_COMMAND_ACK = '1') then
								numlock_led <= numlock;
								capslock_led <= capslock;
								LED_state <= s0;
							end if;
					end case;
				end if;
			end if;
		end if;
	end process;
	
	-- Joystick to half-row --
	process (CLOCK, RESET) is
	begin
		if (rising_edge(CLOCK)) then
			if (RESET = '1') then
				joy1_row_4 <= (others => '1');
				joy2_row_3 <= (others => '1');
				
			else
				-- bit       : 7 6 5 4 3 2 1 0
				-- state     : R L D U T E B A
				-- sin1 keys : 7 6 8 9 - - - 0
				-- sin2 keys : 2 1 3 4 - - - 5
				-- sin1 xtra : - - - - O I P -
				-- sin2 xtra : - - - - W Q E -
				
				-- row 3 keys : 5 4 3 2 1
				joy2_row_3 <= not (
									JOY2_STATE(0) & 
									JOY2_STATE(4) & 
									JOY2_STATE(5) & 
									JOY2_STATE(7) &
									JOY2_STATE(6)
								);
				
				-- row 4 keys : 6 7 8 9 0
				joy1_row_4 <= not (
									JOY1_STATE(6) & 
									JOY1_STATE(7) & 
									JOY1_STATE(5) & 
									JOY1_STATE(4) &
									JOY1_STATE(0)
								);
									
				-- Extra keys --
				-- row 2 keys: T R E W Q
				joy2_row_2 <= "11" & not (
									JOY2_STATE(1) &
									JOY2_STATE(3) &
									JOY2_STATE(2)
								);
								
				-- row 5 keys: Y U I O P
				joy1_row_5 <= "11" & not (
									JOY1_STATE(2) &
									JOY1_STATE(3) &
									JOY1_STATE(1)
								);
			end if;
		end if;
	end process;
	
	-- Device to Host : Key translation --
	process (CLOCK, RESET) is
	begin
		if (rising_edge(CLOCK)) then
			if (RESET = '1') then
				extended <= '0';
				release <= '0';
				numlock <= '1';
				capslock <= '0';
				shift <= '0';
				alt <= '0';
				
				clear_halfrows(half_row_0, half_row_1, half_row_2,
									half_row_3, half_row_4, half_row_5,
									half_row_6, half_row_7);
			else
				if (VALID = '1') then
					if (PS2_SCAN_CODE = x"E0") then
						extended <= '1';
					elsif (PS2_SCAN_CODE = x"F0") then
						release <= '1';
					else
						if (extended = '0') then
							if (shift = '0' and alt = '0') then
								case(PS2_SCAN_CODE) is
								
									when L_SHIFT_key => half_row_0(0) <= release; -- Left shift (CAPS SHIFT)
									--when R_SHIFT_key => half_row_0(0) <= release; -- Right shift (CAPS SHIFT)
									when Z_key => half_row_0(1) <= release; -- Z
									when X_key => half_row_0(2) <= release; -- X
									when C_key => half_row_0(3) <= release; -- C
									when V_key => half_row_0(4) <= release; -- v
									
									when A_key => half_row_1(0) <= release; -- A
									when S_key => half_row_1(1) <= release; -- S
									when D_key => half_row_1(2) <= release; -- D
									when F_key => half_row_1(3) <= release; -- F
									when G_key => half_row_1(4) <= release; -- G
									
									when Q_key => half_row_2(0) <= release; -- Q
									when W_key => half_row_2(1) <= release; -- W
									when E_key => half_row_2(2) <= release; -- E
									when R_key => half_row_2(3) <= release; -- R
									when T_key => half_row_2(4) <= release; -- T
								
									when ONE_key => half_row_3(0) <= release; -- 1
									when TWO_key => half_row_3(1) <= release; -- 2
									when THREE_key => half_row_3(2) <= release; -- 3
									when FOUR_key => half_row_3(3) <= release; -- 4
									when FIVE_key => half_row_3(4) <= release; -- 5
									
									when ZERO_key => half_row_4(0) <= release; -- 0
									when NINE_key => half_row_4(1) <= release; -- 9
									when EIGHT_key => half_row_4(2) <= release; -- 8
									when SEVEN_key => half_row_4(3) <= release; -- 7
									when SIX_key => half_row_4(4) <= release; -- 6
									
									when P_key => half_row_5(0) <= release; -- P
									when O_key => half_row_5(1) <= release; -- O
									when I_key => half_row_5(2) <= release; -- I
									when U_key => half_row_5(3) <= release; -- U
									when Y_key => half_row_5(4) <= release; -- Y
									
									when ENTER_key => half_row_6(0) <= release; -- ENTER
									when L_key => half_row_6(1) <= release; -- L
									when K_key => half_row_6(2) <= release; -- K
									when J_key => half_row_6(3) <= release; -- J
									when H_key => half_row_6(4) <= release; -- H
									
									when CTRL_key => half_row_7(1) <= release; -- CTRL LEFT (Symbol Shift)
									when M_key => half_row_7(2) <= release; -- M
									when N_key => half_row_7(3) <= release; -- N
									when B_key => half_row_7(4) <= release; -- B
									
									
									-- Other special keys sent to the ULA as key combinations
									when BACKSPACE_key =>	half_row_0(0) <= release; -- Backspace (CAPS 0)
																	half_row_4(0) <= release;
									when CAPSLOCK_key =>	half_row_0(0) <= release; -- Caps lock (CAPS 2)
																half_row_3(1) <= release;
									when ESC_key =>	half_row_0(0) <= release; -- Escape (CAPS SPACE)
															half_row_7(0) <= release;
									when TAB_key =>	half_row_0(0) <= release; -- TAB (EXTENDED) (CAPS SYMBOL)
															half_row_7(1) <= release;
									when SQUOTE_key =>	half_row_7(1) <= release; -- (') (SYMB 7)
																half_row_4(3) <= release;
									
									when HYPHEN_key =>	half_row_7(1) <= release; -- (-) (SYMB J)
																half_row_6(3) <= release;
									when COMMA_key =>	half_row_7(1) <= release; -- (,) (SYMB N)
															half_row_7(3) <= release;
									when DOT_key =>	half_row_7(1) <= release; -- (.) (SYMB M)
															half_row_7(2) <= release;
									
									-- PS/2 Keys --
									when R_SHIFT_key =>	shift <= '1';			  -- SHIFT (right)
									
									when others =>
										null;
										
								end case;
								
								-- Because these keys can be nonexistant depending on the setting PT/ENG
								if (PS2_SCAN_CODE = FWSLASH_key) then
									half_row_7(1) <= release; -- (/) (SYMB V)
									half_row_0(4) <= release;
								elsif (PS2_SCAN_CODE = EQUAL_key) then
									half_row_7(1) <= release; -- (=) (SYMB L)
									half_row_6(1) <= release;
								elsif (PS2_SCAN_CODE = LESS_key) then
									half_row_7(1) <= release; -- (<) (SYMB R)
									half_row_2(3) <= release;
								elsif (PS2_SCAN_CODE = SEMICOLON_key) then
									half_row_7(1) <= release; -- (;) (SYMB O)
									half_row_5(1) <= release;
								elsif (PS2_SCAN_CODE = PLUS_key) then
									half_row_7(1) <= release; -- (+) (SYMB K)
									half_row_6(2) <= release;
								end if;
								
								-- NUMPAD --
								if (numlock = '1') then
									case(PS2_SCAN_CODE) is
										when X"69" =>	half_row_3(0) <= release; -- 1
										when X"72" =>	half_row_3(1) <= release; -- 2
										when X"7A" =>	half_row_3(2) <= release; -- 3
										when X"6B" =>	half_row_3(3) <= release; -- 4
										when X"73" =>	half_row_3(4) <= release; -- 5			
										
										when x"70" =>	half_row_4(0) <= release; -- 0
										when X"7D" =>	half_row_4(1) <= release; -- 9
										when X"75" =>	half_row_4(2) <= release; -- 8
										when X"6C" =>	half_row_4(3) <= release; -- 7
										when X"74" =>	half_row_4(4) <= release; -- 6
													
										when X"71" =>	half_row_7(1) <= release; -- (.) (SYMB M)
															half_row_7(2) <= release;					
															
										when others =>
											null;
									end case;
								end if;
							
							-- SHIFT HELD --
							elsif(shift = '1') then
								case(PS2_SCAN_CODE) is
									
									-- Speccy top numbers --
									when EXCLAMATION_key =>	half_row_7(1) <= release; -- (!) (SYMB 1)
																	half_row_3(0) <= release;
									when HASH_key =>	half_row_7(1) <= release; -- (#) (SYMB 3)
															half_row_3(2) <= release;
									when DOLLAR_key =>	half_row_7(1) <= release; -- ($) (SYMB 4)
																half_row_3(3) <= release;
									when PERCENT_key =>	half_row_7(1) <= release; -- (%) (SYMB 5)
																half_row_3(4) <= release;
									when AND_key =>	half_row_7(1) <= release; -- (&) (SYMB 6)
															half_row_4(4) <= release;
									when OPEN_PAR_key =>	half_row_7(1) <= release; -- '(' (SYMB 8)
																half_row_4(2) <= release;
									when CLOSE_PAR_key =>	half_row_7(1) <= release; -- ')' (SYMB 9)
														half_row_4(1) <= release;
									when HYPHEN_key =>	half_row_7(1) <= release; -- (_) (SYMB 0)
																half_row_4(0) <= release;
									
									-- Other --
									when GREAT_key =>	half_row_7(1) <= release; -- (>) (SYMB T)
															half_row_2(4) <= release;
									when DQUOTE_key =>	half_row_7(1) <= release; -- (") (SYMB P)
																half_row_5(0) <= release;
									when COLON_key =>	half_row_7(1) <= release; -- (:) (SYMB Z)
															half_row_0(1) <= release;
									when QUESTION_key =>	half_row_7(1) <= release; -- (?) (SYMB C)
																half_row_0(3) <= release;
									when AST_key =>	half_row_7(1) <= release; -- (*) (SYMB B)
															half_row_7(4) <= release;
																	
									-- Capital Letters --
									-- half_row_0(0)
									when Z_key =>	half_row_0(1) <= release; -- Z
														half_row_0(0) <= release;
									when X_key =>	half_row_0(2) <= release; -- X
														half_row_0(0) <= release;
									when C_key =>	half_row_0(3) <= release; -- C
														half_row_0(0) <= release;
									when V_key =>	half_row_0(4) <= release; -- v
														half_row_0(0) <= release;
									
									when A_key =>	half_row_1(0) <= release; -- A
														half_row_0(0) <= release;
									when S_key =>	half_row_1(1) <= release; -- S
														half_row_0(0) <= release;
									when D_key =>	half_row_1(2) <= release; -- D
														half_row_0(0) <= release;
									when F_key =>	half_row_1(3) <= release; -- F
														half_row_0(0) <= release;
									when G_key =>	half_row_1(4) <= release; -- G
														half_row_0(0) <= release;
									
									when Q_key =>	half_row_2(0) <= release; -- Q
														half_row_0(0) <= release;
									when W_key =>	half_row_2(1) <= release; -- W
														half_row_0(0) <= release;
									when E_key =>	half_row_2(2) <= release; -- E
														half_row_0(0) <= release;
									when R_key =>	half_row_2(3) <= release; -- R
														half_row_0(0) <= release;
									when T_key =>	half_row_2(4) <= release; -- T
														half_row_0(0) <= release;
									
									when P_key =>	half_row_5(0) <= release; -- P
														half_row_0(0) <= release;
									when O_key =>	half_row_5(1) <= release; -- O
														half_row_0(0) <= release;
									when I_key =>	half_row_5(2) <= release; -- I
														half_row_0(0) <= release;
									when U_key =>	half_row_5(3) <= release; -- U
														half_row_0(0) <= release;
									when Y_key =>	half_row_5(4) <= release; -- Y
														half_row_0(0) <= release;
									
									when L_key =>	half_row_6(1) <= release; -- L
														half_row_0(0) <= release;
									when K_key =>	half_row_6(2) <= release; -- K
														half_row_0(0) <= release;
									when J_key =>	half_row_6(3) <= release; -- J
														half_row_0(0) <= release;
									when H_key =>	half_row_6(4) <= release; -- H
														half_row_0(0) <= release;
									
									when M_key =>	half_row_7(2) <= release; -- M
														half_row_0(0) <= release;
									when N_key =>	half_row_7(3) <= release; -- N
														half_row_0(0) <= release;
									when B_key =>	half_row_7(4) <= release; -- B
														half_row_0(0) <= release;
									
									-- To register letting go of SHIFT -
									when R_SHIFT_key =>	shift <= '0';			  -- SHIFT (right)
														-- To remove problem with shift being let go before the button
														-- Forces all rows to let go
														clear_halfrows(half_row_0, half_row_1, half_row_2,
																			half_row_3, half_row_4, half_row_5,
																			half_row_6, half_row_7);
									
									when others =>
											null;
								end case;
								
								-- Because these keys can be nonexistant depending on the setting PT/ENG
								if (PS2_SCAN_CODE = SHIFT_AT_key) then
									half_row_7(1) <= release; -- (@) (SYMB 2)
									half_row_3(1) <= release;
								elsif (PS2_SCAN_CODE = SHIFT_FWSLASH_key) then
									half_row_7(1) <= release; -- (/) (SYMB V)
									half_row_0(4) <= release;
								elsif (PS2_SCAN_CODE = SHIFT_EQUAL_key) then
									half_row_7(1) <= release; -- (=) (SYMB L)
									half_row_6(1) <= release;
								elsif (PS2_SCAN_CODE = SHIFT_LESS_key) then
									half_row_7(1) <= release; -- (<) (SYMB R)
									half_row_2(3) <= release;
								elsif (PS2_SCAN_CODE = SHIFT_SEMICOLON_key) then
									half_row_7(1) <= release; -- (;) (SYMB O)
									half_row_5(1) <= release;
								elsif (PS2_SCAN_CODE = SHIFT_PLUS_key) then
									half_row_7(1) <= release; -- (+) (SYMB K)
									half_row_6(2) <= release;
								end if;
							
							-- ALT HELD --
							elsif(alt = '1') then						
								if (PS2_SCAN_CODE = ALT_AT_key) then
									half_row_7(1) <= release; -- (@) (SYMB 2)
									half_row_3(1) <= release;
								elsif (PS2_SCAN_CODE = ALT_key) then
									alt <= '0';			  -- ALT (right)
									clear_halfrows(half_row_0, half_row_1, half_row_2,
														half_row_3, half_row_4, half_row_5,
														half_row_6, half_row_7);
								end if;
							
							end if;
							
						-- NUMPAD SHIFT HELD OR OFF --
							if (shift = '1' or numlock = '0') then
								case(PS2_SCAN_CODE) is
--									when X"4a" =>	half_row_7(1) <= release; -- (/) (SYMB V)
--														half_row_0(4) <= release;
									when X"69" =>	half_row_0(0) <= release; -- End (INV VIDEO) (CAPS 4)
														half_row_3(3) <= release;
									when X"72" =>	half_row_0(0) <= release; -- Down (CAPS 6)
														half_row_4(4) <= release;
--									when X"7A" =>	half_row_3(2) <= release; -- PgDown
									when X"6B" =>	half_row_0(0) <= release; -- Left (CAPS 5)
														half_row_3(4) <= release;
--									when X"73" =>	half_row_3(4) <= release; -- N/A		
									
									when x"70" =>	half_row_0(0) <= release; -- Insert (EDIT) (CAPS 1)
														half_row_3(0) <= release;
--									when X"7D" =>	half_row_4(1) <= release; -- PgUp
									when X"75" =>	half_row_0(0) <= release; -- Up (CAPS 7)
														half_row_4(3) <= release;
									when X"6C" =>	half_row_0(0) <= release; -- Home (TRUE VIDEO) (CAPS 3)
														half_row_3(2) <= release;
									when X"74" =>	half_row_0(0) <= release; -- Right (CAPS 8)
														half_row_4(2) <= release;
									
--									when X"71" =>	half_row_7(1) <= release; -- Delete
--														half_row_7(2) <= release;
														
									when others =>
										null;
								end case;
							end if;
							
							-- SAME WITH OR WITHOUT SHIFT
							case (PS2_SCAN_CODE) is
								when X"29" => half_row_7(0) <= release; -- SPACE
								
								-- NUMPAD --
								when X"7B" =>	half_row_7(1) <= release; -- (-) (SYMB J)
													half_row_6(3) <= release;
								when X"79" =>	half_row_7(1) <= release; -- (+) (SYMB K)
													half_row_6(2) <= release;
								when X"7C" =>	half_row_7(1) <= release; -- (*) (SYMB B)
													half_row_7(4) <= release;
													
								when others =>
										null;
							end case;
							
							-- Toggle keys --
							if (release = '0') then
								case(PS2_SCAN_CODE) is
									when CAPSLOCK_key => capslock <= not capslock; -- Caps Lock (registered for LED)
									when NUMLOCK_key =>	numlock <= not numlock; -- Numlock
									
									when others =>
										null;
								end case;
							end if;
							
						-- EXTENDED CODES (E0XXh) --
						else
							if (shift = '0' and alt = '0') then
								case(PS2_SCAN_CODE) is
									-- Cursor Keys --
									when X"6B" => 	half_row_0(0) <= release; -- Left (CAPS 5)
														half_row_3(4) <= release;
									when X"72" =>	half_row_0(0) <= release; -- Down (CAPS 6)
														half_row_4(4) <= release;
									when X"75" =>	half_row_0(0) <= release; -- Up (CAPS 7)
														half_row_4(3) <= release;
									when X"74" =>	half_row_0(0) <= release; -- Right (CAPS 8)
														half_row_4(2) <= release;
									
									-- Others --
									when X"69" =>	half_row_0(0) <= release; -- End (INV VIDEO) (CAPS 4)
														half_row_3(3) <= release;
									when X"6C" =>	half_row_0(0) <= release; -- Home (TRUE VIDEO) (CAPS 3)
														half_row_3(2) <= release;
									when X"70" =>	half_row_0(0) <= release; -- Insert (EDIT) (CAPS 1)
														half_row_3(0) <= release;
									when X"2F" =>	half_row_0(0) <= release; -- Menu (GRAPH) (CAPS 9)
														half_row_4(1) <= release;
														
									-- PS/2 Keys --
									when ALT_key =>	alt <= '1';			  -- ALT (right) Alt Gr
									
									when others =>
										null;
								end case;
								
								-- NUMPAD EXTENDED --
								if (PS2_SCAN_CODE = ENTER_key) then
									half_row_6(0) <= release; -- ENTER
								end if;

							-- ALT held EXTENDED --
							elsif (alt = '1') then
								case(PS2_SCAN_CODE) is
									-- To register letting go of ALT -
									when ALT_key =>	alt <= '0';			  -- ALT (right) Alt Gr
														clear_halfrows(half_row_0, half_row_1, half_row_2,
																			half_row_3, half_row_4, half_row_5,
																			half_row_6, half_row_7);
									
									when others =>
											null;
								end case;
							end if;
							
							-- NUMPAD EXTENDED indifferent --
							if (PS2_SCAN_CODE = X"4a") then
								half_row_7(1) <= release; -- (/) (SYMB V)
								half_row_0(4) <= release;
							end if;
						end if;
						
						-- cancel extended and release flags for the next key
						extended <= '0';
						release <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;
	
end Behavior;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyboard_top is
	port(
		CLOCK, RESET : in std_logic;
		PS2_CLOCK, PS2_DATA : inout std_logic;
		NATIVE_DATA : in std_logic_vector(4 downto 0);
		NATnPS2 : in std_logic;
		ADDRESS : in std_logic_vector(7 downto 0);
		JOY1_STATE : in std_logic_vector(7 downto 0);
		JOY2_STATE : in std_logic_vector(7 downto 0);
		KEY_DATA : out std_logic_vector(4 downto 0)
	);
end keyboard_top;

architecture Behavior of keyboard_top is
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
	
	component input_receiver is
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
	end component;
		
	signal ps2_scan_code : std_logic_vector(7 downto 0);
	signal key_valid, key_error : std_logic;
	
	-- HOST to Device --
	signal ps2_command : std_logic_vector(7 downto 0);
	signal ps2_command_en : std_logic;
	
	signal ps2_command_ack, ps2_command_err : std_logic;
begin
	PS2 : PS2_Controller port map(
				CLOCK_50 => CLOCK,
				RESET => RESET,
				THE_COMMAND => ps2_command,
				SEND_COMMAND => ps2_command_en,
				
				PS2_CLK => PS2_CLOCK,
				PS2_DAT => PS2_DATA,
				
				RECEIVED_DATA => ps2_scan_code,
				RECEIVED_DATA_EN => key_valid,
				COMMAND_WAS_SENT => ps2_command_ack,
				ERROR_COMMUNICATION_TIMED_OUT => ps2_command_err
		);
	
	input_rcvr : input_receiver port map(
				CLOCK => CLOCK,
				RESET => RESET,
				VALID => key_valid,
				ADDRESS => ADDRESS,
				PS2_SCAN_CODE => ps2_scan_code,
				NATIVE_DATA => NATIVE_DATA,
				NATnPS2 => NATnPS2, 
				KEY_DATA => KEY_DATA,
				
				JOY1_STATE => JOY1_STATE,
				JOY2_STATE => JOY2_STATE,
				
				PS2_COMMAND => ps2_command,
				PS2_COMMAND_EN => ps2_command_en,
				PS2_COMMAND_ACK => ps2_command_ack,
				PS2_COMMAND_ERR => ps2_command_err
		);
end Behavior;
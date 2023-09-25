LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

PACKAGE constants IS
	--------
	-- TB --
	--------
	constant native_n_ps2 : std_logic; 						-- Keyboard selection
	constant video_mode : std_logic_vector(1 downto 0);

	---------------------------------------------------------------------------

	--------------
	-- Keyboard --
	--------------
	
	-- Qwerty keyboard --
	constant ONE_key : std_logic_vector(7 downto 0);
	constant TWO_key : std_logic_vector(7 downto 0);
	constant THREE_key : std_logic_vector(7 downto 0);
	constant FOUR_key : std_logic_vector(7 downto 0);
	constant FIVE_key : std_logic_vector(7 downto 0);
	constant SIX_key : std_logic_vector(7 downto 0);
	constant SEVEN_key : std_logic_vector(7 downto 0);
	constant EIGHT_key : std_logic_vector(7 downto 0);
	constant NINE_key : std_logic_vector(7 downto 0);
	constant ZERO_key : std_logic_vector(7 downto 0);
	
	constant Q_key : std_logic_vector(7 downto 0);
	constant W_key : std_logic_vector(7 downto 0);
	constant E_key : std_logic_vector(7 downto 0);
	constant R_key : std_logic_vector(7 downto 0);
	constant T_key : std_logic_vector(7 downto 0);
	constant Y_key : std_logic_vector(7 downto 0);
	constant U_key : std_logic_vector(7 downto 0);
	constant I_key : std_logic_vector(7 downto 0);
	constant O_key : std_logic_vector(7 downto 0);
	constant P_key : std_logic_vector(7 downto 0);
	
	constant A_key : std_logic_vector(7 downto 0);
	constant S_key : std_logic_vector(7 downto 0);
	constant D_key : std_logic_vector(7 downto 0);
	constant F_key : std_logic_vector(7 downto 0);
	constant G_key : std_logic_vector(7 downto 0);
	constant H_key : std_logic_vector(7 downto 0);
	constant J_key : std_logic_vector(7 downto 0);
	constant K_key : std_logic_vector(7 downto 0);
	constant L_key : std_logic_vector(7 downto 0);
	
	constant Z_key : std_logic_vector(7 downto 0);
	constant X_key : std_logic_vector(7 downto 0);
	constant C_key : std_logic_vector(7 downto 0);
	constant V_key : std_logic_vector(7 downto 0);
	constant B_key : std_logic_vector(7 downto 0);
	constant N_key : std_logic_vector(7 downto 0);
	constant M_key : std_logic_vector(7 downto 0);
	
	constant DOT_key : std_logic_vector(7 downto 0);
	constant COMMA_key : std_logic_vector(7 downto 0);
	
	constant ENTER_key : std_logic_vector(7 downto 0);
	constant CTRL_key : std_logic_vector(7 downto 0);
	constant ALT_key : std_logic_vector(7 downto 0);
	constant BACKSPACE_key : std_logic_vector(7 downto 0);
	constant NUMLOCK_key : std_logic_vector(7 downto 0);

	constant CAPSLOCK_key : std_logic_vector(7 downto 0);
	constant ESC_key : std_logic_vector(7 downto 0);
	constant TAB_key : std_logic_vector(7 downto 0);
	
	constant L_SHIFT_key : std_logic_vector(7 downto 0); -- interpreted as caps shift
	
	constant R_SHIFT_key : std_logic_vector(7 downto 0); -- for PS/2 keyboard shortcuts, doesn't work as spectrum's caps SHIFT
	
	constant HYPHEN_key : std_logic_vector(7 downto 0); -- -
	constant FWSLASH_key : std_logic_vector(7 downto 0); -- /
	constant EQUAL_key : std_logic_vector(7 downto 0); -- =
	constant SQUOTE_key : std_logic_vector(7 downto 0); -- `
	constant LESS_key : std_logic_vector(7 downto 0); -- <
	constant SEMICOLON_key : std_logic_vector(7 downto 0); -- ;
	constant PLUS_key : std_logic_vector(7 downto 0); -- +
	
	-- SHIFT keys --
	constant EXCLAMATION_key : std_logic_vector(7 downto 0); -- !
	constant DQUOTE_key : std_logic_vector(7 downto 0); -- "
	constant SHIFT_AT_key : std_logic_vector(7 downto 0); -- @
	constant HASH_key : std_logic_vector(7 downto 0); -- #
	constant DOLLAR_key : std_logic_vector(7 downto 0); -- $
	constant PERCENT_key : std_logic_vector(7 downto 0); -- %
	constant EXP_key : std_logic_vector(7 downto 0); -- ^
	constant AND_key : std_logic_vector(7 downto 0); -- &
	constant SHIFT_FWSLASH_key : std_logic_vector(7 downto 0); -- /
	constant OPEN_PAR_key : std_logic_vector(7 downto 0); -- (
	constant CLOSE_PAR_key : std_logic_vector(7 downto 0); -- )
	constant SHIFT_EQUAL_key : std_logic_vector(7 downto 0); -- =
	constant GREAT_key : std_logic_vector(7 downto 0); -- >
	constant SHIFT_LESS_key : std_logic_vector(7 downto 0); -- <
	constant SHIFT_SEMICOLON_key : std_logic_vector(7 downto 0); -- ;
	constant COLON_key : std_logic_vector(7 downto 0); -- :
	constant QUESTION_key : std_logic_vector(7 downto 0); -- ?
	constant AST_key : std_logic_vector(7 downto 0); -- *
	constant SHIFT_PLUS_key : std_logic_vector(7 downto 0); -- +

	-- ALT keys --
	constant ALT_AT_key : std_logic_vector(7 downto 0); -- @
	
	
	-----------
	-- Audio --
	-----------
	constant audio_ref_clk : integer;
	constant audio_sample_rate : integer;
	constant audio_data_width : integer;
	constant audio_channel_num : integer;
	
	-----------
	-- VIDEO --
	-----------
	-- Color values --
	constant no_color : std_logic_vector(7 downto 0);
	constant normal_color : std_logic_vector(7 downto 0);
	constant bright_color : std_logic_vector(7 downto 0);
	
	-- Border limits for different sizes/video modes
	constant x_4x_init, y_4x_init : unsigned(9 downto 0);
	constant x_4x_end : unsigned(9 downto 0);
	constant y_4x_end : unsigned(9 downto 0);
	
	constant x_2x_init : unsigned(9 downto 0);
	constant x_2x_end : unsigned(9 downto 0);
	constant y_2x_init : unsigned(9 downto 0);
	constant y_2x_end : unsigned(9 downto 0);
	
	constant x_native_init : unsigned(9 downto 0);
	constant x_native_end : unsigned(9 downto 0);
	constant y_native_init : unsigned(9 downto 0);
	constant y_native_end : unsigned(9 downto 0);
	
	constant x_int_size : integer;
	constant y_int_size : integer;
	
	constant ATT_SIZE : integer;
	
	-- VGA controller --
	constant h_pulse, h_bp, h_pixels, h_fp : integer;
	constant v_pulse, v_bp, v_pixels, v_fp : integer;
	constant h_pol, v_pol : std_logic;

end package;

package body constants is
	--------
	-- TB --
	--------
	constant native_n_ps2 : std_logic := '0';							-- PS2 keyboard
	constant video_mode : std_logic_vector(1 downto 0) := "00"; -- 4x no border video
	
	---------------------------------------------------------------------------
	
	--------------
	-- Keyboard --
	--------------
	
	-- Qwerty keyboard --
	constant ONE_key : std_logic_vector(7 downto 0) := x"16";
	constant TWO_key : std_logic_vector(7 downto 0) := X"1e";
	constant THREE_key : std_logic_vector(7 downto 0) := X"26";
	constant FOUR_key : std_logic_vector(7 downto 0) := X"25";
	constant FIVE_key : std_logic_vector(7 downto 0) := X"2E";
	constant SIX_key : std_logic_vector(7 downto 0) := X"36";
	constant SEVEN_key : std_logic_vector(7 downto 0) := X"3d";
	constant EIGHT_key : std_logic_vector(7 downto 0) := X"3e";
	constant NINE_key : std_logic_vector(7 downto 0) := X"46";
	constant ZERO_key : std_logic_vector(7 downto 0) := X"45";
	
	constant Q_key : std_logic_vector(7 downto 0) := x"15";
	constant W_key : std_logic_vector(7 downto 0) := X"1d";
	constant E_key : std_logic_vector(7 downto 0) := X"24";
	constant R_key : std_logic_vector(7 downto 0) := X"2d";
	constant T_key : std_logic_vector(7 downto 0) := X"2c";
	constant Y_key : std_logic_vector(7 downto 0) := X"35";
	constant U_key : std_logic_vector(7 downto 0) := X"3c";
	constant I_key : std_logic_vector(7 downto 0) := X"43";
	constant O_key : std_logic_vector(7 downto 0) := X"44";
	constant P_key : std_logic_vector(7 downto 0) := X"4d";
	
	constant A_key : std_logic_vector(7 downto 0) := X"1c";
	constant S_key : std_logic_vector(7 downto 0) := X"1b";
	constant D_key : std_logic_vector(7 downto 0) := X"23";
	constant F_key : std_logic_vector(7 downto 0) := X"2b";
	constant G_key : std_logic_vector(7 downto 0) := X"34";
	constant H_key : std_logic_vector(7 downto 0) := X"33";
	constant J_key : std_logic_vector(7 downto 0) := X"3b";
	constant K_key : std_logic_vector(7 downto 0) := X"42";
	constant L_key : std_logic_vector(7 downto 0) := X"4b";
	
	constant Z_key : std_logic_vector(7 downto 0) := X"1a";
	constant X_key : std_logic_vector(7 downto 0) := X"22";
	constant C_key : std_logic_vector(7 downto 0) := X"21";
	constant V_key : std_logic_vector(7 downto 0) := x"2A";
	constant B_key : std_logic_vector(7 downto 0) := X"32";
	constant N_key : std_logic_vector(7 downto 0) := X"31";
	constant M_key : std_logic_vector(7 downto 0) := X"3a";
	
	constant DOT_key : std_logic_vector(7 downto 0) := X"49";
	constant COMMA_key : std_logic_vector(7 downto 0) := X"41";
	
	constant ENTER_key : std_logic_vector(7 downto 0) := x"5a";
	constant CTRL_key : std_logic_vector(7 downto 0) := x"14";
	constant ALT_key : std_logic_vector(7 downto 0) := x"11";
	constant BACKSPACE_key : std_logic_vector(7 downto 0) := x"66";
	constant NUMLOCK_key : std_logic_vector(7 downto 0) := x"77";

	constant CAPSLOCK_key : std_logic_vector(7 downto 0) := X"58";
	constant ESC_key : std_logic_vector(7 downto 0) := X"76";
	constant TAB_key : std_logic_vector(7 downto 0) := X"0d";
	
	constant L_SHIFT_key : std_logic_vector(7 downto 0) := x"12"; -- interpreted as caps shift
	
	constant R_SHIFT_key : std_logic_vector(7 downto 0) := X"59"; -- for PS/2 keyboard shortcuts, doesn't work as spectrum's caps SHIFT

	-- Assuming numlock is universal, it is hardcored in input_receiver.vhd
	-- as well as the arrow keys and other extended ones, such as Home and Insert
	
	------------------------
	-- CONFIGURE KEYBOARD --
	------------------------
	
	-- UNCOMMENT KEYBOARD CONFIG YOU WANT
	-- or change keycodes if idiom is not here
	
	-- PT Keyboard --
	
	constant HYPHEN_key : std_logic_vector(7 downto 0) := X"4A"; -- -
	constant FWSLASH_key : std_logic_vector(7 downto 0) := X"FF"; -- /
	constant EQUAL_key : std_logic_vector(7 downto 0) := X"FF"; -- =
	constant SQUOTE_key : std_logic_vector(7 downto 0) := X"4E"; -- '
	constant LESS_key : std_logic_vector(7 downto 0) := x"61"; -- <
	constant SEMICOLON_key : std_logic_vector(7 downto 0) := x"FF"; -- ;
	constant PLUS_key : std_logic_vector(7 downto 0) := x"54"; -- +
	
	-- SHIFT keys --
	constant EXCLAMATION_key : std_logic_vector(7 downto 0) := ONE_key; -- !
	constant DQUOTE_key : std_logic_vector(7 downto 0) := TWO_key; -- "
	constant SHIFT_AT_key : std_logic_vector(7 downto 0) := X"FF"; -- @
	constant HASH_key : std_logic_vector(7 downto 0) := THREE_key; -- #
	constant DOLLAR_key : std_logic_vector(7 downto 0) := FOUR_key; -- $
	constant PERCENT_key : std_logic_vector(7 downto 0) := FIVE_key; -- %
	constant EXP_key : std_logic_vector(7 downto 0) := X"5D"; -- ^
	constant AND_key : std_logic_vector(7 downto 0) := SIX_key; -- &
	constant SHIFT_FWSLASH_key : std_logic_vector(7 downto 0) := SEVEN_key; -- /
	constant OPEN_PAR_key : std_logic_vector(7 downto 0) := EIGHT_key; -- (
	constant CLOSE_PAR_key : std_logic_vector(7 downto 0) := NINE_key; -- )
	constant SHIFT_EQUAL_key : std_logic_vector(7 downto 0) := ZERO_key; -- =
	constant GREAT_key : std_logic_vector(7 downto 0) := LESS_key; -- >
	constant SHIFT_LESS_key : std_logic_vector(7 downto 0) := x"FF"; -- <
	constant SHIFT_SEMICOLON_key : std_logic_vector(7 downto 0) := COMMA_key; -- ;
	constant COLON_key : std_logic_vector(7 downto 0) := DOT_key; -- :
	constant QUESTION_key : std_logic_vector(7 downto 0) := SQUOTE_key; -- ?
	constant AST_key : std_logic_vector(7 downto 0) := PLUS_key; -- *
	constant SHIFT_PLUS_key : std_logic_vector(7 downto 0) := x"FF"; -- +

	-- ALT keys --
	constant ALT_AT_key : std_logic_vector(7 downto 0) := TWO_key; -- @
	
	
	-- ENG Keyboard --

--	constant HYPHEN_key : std_logic_vector(7 downto 0) := X"4E"; -- -
--	constant FWSLASH_key : std_logic_vector(7 downto 0) := X"4A"; -- /
--	constant EQUAL_key : std_logic_vector(7 downto 0) := X"55"; -- =
--	constant SQUOTE_key : std_logic_vector(7 downto 0) := X"52"; -- '
--	constant LESS_key : std_logic_vector(7 downto 0) := x"FF"; -- <
--	constant SEMICOLON_key : std_logic_vector(7 downto 0) := x"4c"; -- ;
--	constant PLUS_key : std_logic_vector(7 downto 0) := x"FF"; -- +
--
--	-- SHIFT keys --
--	constant EXCLAMATION_key : std_logic_vector(7 downto 0) := ONE_key; -- !
--	constant DQUOTE_key : std_logic_vector(7 downto 0) := SQUOTE_key; -- "
--	constant SHIFT_AT_key : std_logic_vector(7 downto 0) := X"1E"; -- @
--	constant HASH_key : std_logic_vector(7 downto 0) := THREE_key; -- #
--	constant DOLLAR_key : std_logic_vector(7 downto 0) := FOUR_key; -- $
--	constant PERCENT_key : std_logic_vector(7 downto 0) := FIVE_key; -- %
--	constant EXP_key : std_logic_vector(7 downto 0) := SIX_key; -- ^
--	constant AND_key : std_logic_vector(7 downto 0) := SEVEN_key; -- &
--	constant SHIFT_FWSLASH_key : std_logic_vector(7 downto 0) := x"FF"; -- /
--	constant OPEN_PAR_key : std_logic_vector(7 downto 0) := NINE_key; -- (
--	constant CLOSE_PAR_key : std_logic_vector(7 downto 0) := ZERO_key; -- )
--	constant SHIFT_EQUAL_key : std_logic_vector(7 downto 0) := x"FF"; -- =
--	constant GREAT_key : std_logic_vector(7 downto 0) := DOT_key; -- >
--	constant SHIFT_LESS_key : std_logic_vector(7 downto 0) := COMMA_key; -- <
--	constant SHIFT_SEMICOLON_key : std_logic_vector(7 downto 0) := x"FF"; -- ;
--	constant COLON_key : std_logic_vector(7 downto 0) := SEMICOLON_key; -- :
--	constant QUESTION_key : std_logic_vector(7 downto 0) := FWSLASH_key; -- ?
--	constant AST_key : std_logic_vector(7 downto 0) := EIGHT_key; -- *
--	constant SHIFT_PLUS_key : std_logic_vector(7 downto 0) := EQUAL_key; -- +
--
--	-- ALT keys --
--	constant ALT_AT_key : std_logic_vector(7 downto 0) := x"ff"; -- @
	
	-----------
	-- Audio --
	-----------
	constant audio_ref_clk : integer := 18432000; -- 18.432 MHz
	constant audio_sample_rate : integer := 48000; -- 48KHz
	constant audio_data_width : integer := 1; -- 1 bit
	constant audio_channel_num : integer := 2; -- 2 channels
	-----------
	-- VIDEO --
	-----------
	constant no_color : std_logic_vector(7 downto 0) := x"00";
	constant normal_color : std_logic_vector(7 downto 0) := x"b2";
	constant bright_color :  std_logic_vector(7 downto 0) := x"e6";
	
	-- 1024x768 --
	constant x_4x_init, y_4x_init : unsigned(9 downto 0) := (others => '0');
	constant x_4x_end : unsigned(9 downto 0) := "1111111111"; -- 1023
	constant y_4x_end : unsigned(9 downto 0) := "1011111111"; -- 767
	
	-- 512x384 --
	constant x_2x_init : unsigned(9 downto 0) := "0100000000"; -- 256
	constant x_2x_end : unsigned(9 downto 0) := "1100000000"; -- 768
	constant y_2x_init : unsigned(9 downto 0) := "0011000000"; -- 192
	constant y_2x_end : unsigned(9 downto 0) := "1001000000"; -- 576
	
	-- 256x192 --
	constant x_native_init : unsigned(9 downto 0) := "0110000000"; -- 384
	constant x_native_end : unsigned(9 downto 0) := "1010000001"; -- 641 (640 seemed to cut off 1 pixel)
	constant y_native_init : unsigned(9 downto 0) := "0100100000"; -- 288
	constant y_native_end : unsigned(9 downto 0) := "0111100000"; -- 480
	
	constant x_int_size : integer := 1023;
	constant y_int_size : integer := 767;
	
	constant ATT_SIZE : integer := 8;
	
	-- VGA controller --
	constant h_pulse  : INTEGER := 136;    --horiztonal sync pulse width in pixels
   constant h_bp     : INTEGER := 160;    --horiztonal back porch width in pixels
   constant h_pixels : INTEGER := 1024;   --horiztonal display width in pixels
   constant h_fp     : INTEGER := 24;    --horiztonal front porch width in pixels
   constant h_pol    : STD_LOGIC := '0';  --horizontal sync pulse polarity (1 = positive, 0 = negative)
   constant v_pulse  : INTEGER := 6;      --vertical sync pulse width in rows
   constant v_bp     : INTEGER := 29;     --vertical back porch width in rows
   constant v_pixels : INTEGER := 768;   --vertical display width in rows
   constant v_fp     : INTEGER := 3;      --vertical front porch width in rows
   constant v_pol    : STD_LOGIC := '0'; --vertical sync pulse polarity (1 = positive, 0 = negative)
	
end package body constants;
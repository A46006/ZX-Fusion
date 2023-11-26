LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY double_spin_anim_7seg IS
	PORT ( 
			CLOCK_50       : IN STD_LOGIC;
			SET            : IN STD_LOGIC;
			CLR            : IN STD_LOGIC;
			D3, D2, D1, D0 : OUT STD_LOGIC_VECTOR(0 TO 6)
			);
END double_spin_anim_7seg;

ARCHITECTURE Behavior OF double_spin_anim_7seg IS
	component spin_anim_7seg IS
		PORT ( 
				CLK : IN STD_LOGIC;
				SET : IN STD_LOGIC;
				CLR : IN STD_LOGIC;
				D1, D0   : OUT STD_LOGIC_VECTOR(0 TO 6)
				);
	END component;
	
	component spin_ctr IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		cout		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (19 DOWNTO 0)
	);
	END component;

	signal clk2, clk1 : std_logic := '0';
	signal count_num : std_logic_vector(19 DOWNTO 0);
BEGIN
	count : spin_ctr port map (
		clock => CLOCK_50,
		cout => clk1,
		q => count_num
	);

	clk2 <= count_num(19);
	-- slower
	spin2 : spin_anim_7seg port map (
			CLK => clk1,
			SET => SET,
			CLR => CLR,
			D1  => D3,
			D0  => D2
	);

	-- faster
	spin1 : spin_anim_7seg port map (
			CLK => clk2,
			SET => SET,
			CLR => CLR,
			D1  => D1,
			D0  => D0
	);
	
END Behavior;


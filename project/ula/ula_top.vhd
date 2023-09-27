library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula_top is
port (
	CLK			: in std_logic;
	nRESET		: in std_logic;
	
	-- PORT --
	D_IN			:	in	std_logic_vector(7 downto 0);
	D_OUT			:	out	std_logic_vector(7 downto 0);
	ENABLE		:	in	std_logic;
	WR_e			:	in	std_logic;
	
	BORDER_OUT	:	out	std_logic_vector(2 downto 0);
	EAR_OUT		:	out	std_logic;
	MIC_OUT		:	out std_logic;
	
	KEYB_IN		:	in 	std_logic_vector(4 downto 0);
	EAR_IN		:	in	std_logic;
	
	-- COUNT --
	nTCLKA		: in	std_logic; -- Upper Counter Stage Test Clock = nIOREQ and nMREQ and nRD and !nWR
	nTCLKB		: in	std_logic; -- Flash Counter Test Clock = nIOREQ and nMREQ and !nRD and nWR
	
	MREQ_n		: in	std_logic;
	IOREQ_n		: in std_logic;

	TOP_ADDRESS	: in	std_logic_vector(1 downto 0);
	
	nINT			: out	std_logic; -- Interrupt
	CPU_CLK		: out	std_logic; -- 3.5MHz
	FLASH_CLK	: out std_logic; -- 1.56 Hz
	IOREQGTW3_n	: out std_logic
);
	
end ula_top;

architecture Behavior of ula_top is
	component ula_port is
		port (
			CLK			:	in	std_logic;
			nRESET		:	in	std_logic;
			
			-- CPU interface with separate read/write buses
			D_IN			:	in	std_logic_vector(7 downto 0);
			D_OUT			:	out	std_logic_vector(7 downto 0);
			ENABLE		:	in	std_logic;
			WR_e			:	in	std_logic;
			
			BORDER_OUT	:	out	std_logic_vector(2 downto 0);
			EAR_OUT		:	out	std_logic;
			MIC_OUT		:	out std_logic;
			
			KEYB_IN		:	in 	std_logic_vector(4 downto 0);
			EAR_IN		:	in	std_logic	
			);
		end component;
	
	component ula_count is
		port (
			CLK			: in	std_logic; -- 7MHz
			nTCLKA		: in	std_logic; -- Upper Counter Stage Test Clock = nIOREQ and nMREQ and nRD and !nWR
			nTCLKB		: in	std_logic; -- Flash Counter Test Clock = nIOREQ and nMREQ and !nRD and nWR
			nRESET		: in	std_logic;
			
			MREQ_n		: in	std_logic;
			IOREQ_n		: in std_logic;

			TOP_ADDRESS	: in	std_logic_vector(1 downto 0);
			
			nINT			: out	std_logic; -- Interrupt
			CPU_CLK		: out	std_logic; -- 3.5MHz
			FLASH_CLK	: out std_logic; -- 1.56 Hz
			IOREQGTW3_n	: out std_logic
--			C_out : out std_logic_vector(8 downto 0)
			);
		end component;
		
begin
	ula_ports : ula_port port map (
			CLK			=> CLK,
			nRESET		=> nRESET,
			
			D_IN			=> D_IN,
			D_OUT			=> D_OUT,
			ENABLE		=> ENABLE,
			WR_e			=> WR_e,
			
			BORDER_OUT	=> BORDER_OUT,
			EAR_OUT		=> EAR_OUT,
			MIC_OUT		=> MIC_OUT,
			
			KEYB_IN		=> KEYB_IN,
			EAR_IN		=> EAR_IN
	);
	
	ula_counters : ula_count port map(
			CLK			=> CLK,
			nTCLKA		=> nTCLKA,
			nTCLKB		=> nTCLKB,
			nRESET		=> nRESET,
			
			MREQ_n		=> MREQ_n,
			IOREQ_n		=> IOREQ_n,
			TOP_ADDRESS	=> TOP_ADDRESS,
			
			nINT			=> nINT,
			CPU_CLK		=> CPU_CLK,
			FLASH_CLK	=> FLASH_CLK,
			IOREQGTW3_n => IOREQGTW3_n
--			C_out			=> LEDR(8 downto 0)
		);

end Behavior;